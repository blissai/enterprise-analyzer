module Linter
  include Gitbase
  def lint_commit(linter, output_file, remote = false, directory = nil)
    directory = @git_dir if directory.nil?
    quality_tool = linter['quality_tool']
    ext = linter['output_format']
    cmd = lint_command(linter, output_file, directory)
    cmd = "cd #{directory} && #{cmd}" if linter['cd_first']
    begin
      key = "#{@organization}_#{@name}_#{@commit}_#{quality_tool}.#{ext}"
      lint_output = execute_linter_cmd(cmd, output_file, linter['name'], linter['error_code'])
      post_lintfile(key, @commit, lint_output, linter['id']) if remote
    rescue LinterError => e
      @logger.error(e.message)
    rescue Errno::ENOENT
      @logger.info("Dependency Error: #{quality_tool} not installed or not configured correctly...")
    end
  end

  def lint_command(linter, output_file, directory = nil)
    directory = @git_dir if directory.nil?
    linter['quality_command'].gsub('git_dir', directory)
      .gsub('file_name', output_file)
      .gsub('proj_filename', '')
  end

  def execute_linter_cmd(cmd, file_name, linter_name, error_code)
    result = ''
    error_code = -1 if error_code.nil? || error_code.to_s.empty?
    thread_status = Open3.popen2e("#{cmd}") do |_stdin, stdout_err, wait_thr|
      result += stdout_err.read
      wait_thr.value
    end
    if thread_status.exitstatus == error_code
      @logger.error("#{linter_name} - linter failed.")
      File.write(file_name, "#{result} - failtorundocker")
      fail LinterError, result
    else
      unscrubbed = File.read(file_name)
      File.write(file_name, @scrubber.scrub(unscrubbed)) if @scrubber
      File.open(file_name, 'r').read
    end
  end

  # Post lintfile to AWS and notify Bliss
  def post_lintfile(key, commit, output, linter_id)
    @logger.info("\tUploading lint results to AWS...")
    upload_to_aws('bliss-collector-files', key, output)
    lint_payload = { commit: commit, repo_key: @repo_key, linter_id: linter_id,
                     lint_file_location: key, git_dir: @git_dir, bucket: 'bliss-collector-files' }
    http_post("#{@host}/api/commit/lint", lint_payload)
  end

  def partition_and_lint(linter, remote = false)
    parts = Partitioner.new(@git_dir, @logger, linter['partitionable']).create_partitions
    multipart = parts.size > 1
    @logger.info("\tRunning #{linter['quality_tool']} on #{@commit}... This may take a while...")
    Parallel.each_with_index(parts, in_processes: parts.size) do |part, index|
      result_path = multipart ? "/resultpart#{index}.txt" : @output_file
      lint_commit(linter, result_path, remote, part)
    end
    consolidate_output if multipart
  end

  def consolidate_output
    File.truncate(@output_file, 0)
    Dir.glob('/resultpart*.txt').each do |r|
      File.open(@output_file, 'a') do |f|
        f.write("<--LintFilePartition-->\n#{File.read(r)}")
      end
    end
  end
end
