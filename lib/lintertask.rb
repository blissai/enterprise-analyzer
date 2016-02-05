# Stats class for collecting git LOC and other stats
class LinterTask
  include Common
  include Gitbase
  include AwsUploader

  def initialize(git_dir, api_key, host, repo, quick = false)
    init_configuration(git_dir, api_key, host, repo, quick)
    configure_http
    @logger = BlissLogger.new("Linter-#{Time.now.strftime('%d-%m-%y-T%H-%M')}-#{@name}")
    @scrubber = SourceScrubber.new
    @from_date = nil
    @to_date = nil
    @excluded_dirs = @repo['excluded_directories'] || []
  end

  def execute
    @logger.info("Running Linter on #{@name}...")
    metrics = next_batch
    unless metrics.empty?
      starttime = DateTime.parse(metrics.last['commited_at'])
      endtime = DateTime.parse(metrics.first['commited_at'])
      dates = "#{starttime.strftime('%d-%m-%Y')} and #{endtime.strftime('%d-%m-%Y')}"
      @logger.success("Processing Linters between #{dates}")
    end
    metrics.each do |metric|
      commit = metric['commit']
      process_commit(commit)
    end
    # Go back to main branch
    checkout_commit(@git_dir, @repo['branch'])
    @logger.success("Linter finished for #{@name}...")
    @logger.save_log
  end

  def process_commit(commit)
    checkout_commit(@git_dir, commit)
    remove_open_source_files(@git_dir) unless @repo['detect_open_source'] == false
    remove_excluded_directories(@excluded_dirs, @git_dir)
    Dir.mktmpdir do |tmp_dir|
      @linters.each do |linter|
        output_file = File.join(tmp_dir, "#{linter['quality_tool']}.#{linter['output_format']}")
        lint_commit(commit, linter, output_file)
      end
    end
  end

  def lint_commit(commit, linter, output_file)
    quality_tool = linter['quality_tool']
    ext = linter['output_format']
    cmd = lint_command(linter, output_file)
    cmd = "cd #{@git_dir} && #{cmd}" if linter['cd_first']
    begin
      key = "#{@organization}_#{@name}_#{commit}_#{quality_tool}.#{ext}"
      @logger.info("Running #{quality_tool} on #{commit}... This may take a while...")
      lint_output = execute_linter_cmd(cmd, output_file)
      post_lintfile(key, commit, lint_output, linter['id'])
    rescue Errno::ENOENT
      @logger.info("Dependency Error: #{quality_tool} not installed or not configured correctly...")
    rescue LinterError => e
      @logger.error(e.message)
    end
  end

  def lint_command(linter, output_file)
    linter['quality_command'].gsub('git_dir', @git_dir)
      .gsub('file_name', output_file)
      .gsub('proj_filename', '')
  end

  def execute_linter_cmd(cmd, file_name)
    result = ''
    thread_status = Open3.popen2e("#{cmd}") do |_stdin, stdout_err, wait_thr|
      result += stdout_err.read
      wait_thr.value
    end
    if thread_status.exitstatus == 1
      @logger.error('Linting task failed!')
      raise LinterError, result
    end
    File.open(file_name, 'r').read
  end

  private

  def next_batch
    url = "#{@host}/api/gitlog/linters_todo?repo_key=#{@repo_key}"
    url = "#{url}&batch=2" if @quick
    json_return = http_get(url)
    @linters = json_return['linters']
    json_return['metrics']
  end

  # Post lintfile to AWS and notify Bliss
  def post_lintfile(key, commit, output, linter_id)
    puts "\tUploading lint results to AWS...".blue
    upload_to_aws('bliss-collector-files', key, @scrubber.scrub(output))
    lint_payload = { commit: commit, repo_key: @repo_key, linter_id: linter_id,
                     lint_file_location: key, git_dir: @git_dir, bucket: 'bliss-collector-files' }
    http_post("#{@host}/api/commit/lint", lint_payload)
  end
end
