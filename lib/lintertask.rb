# Stats class for collecting git LOC and other stats
class LinterTask
  include Common
  include Gitbase
  include AwsUploader

  def execute(git_dir, api_key, host, repo)
    name = git_dir.split('/').last
    @logger = BlissLogger.new("Linter-#{Time.now.strftime("%d-%m-%y-T%H-%M")}-#{name}")
    @logger.info("Starting Linter.")
    agent = Mechanize.new
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    auth_headers = { 'X-User-Token' => api_key }

    # Count number of lints to process in total
    total_lints_count = 0
    repo_key = repo['repo_key']
    count_json = http_get(agent, "#{host}/api/gitlog/linters_todo_count?repo_key=#{repo_key}", auth_headers)
    count = count_json["linters_todo"].to_i
    total_lints_count += count
    total_lints_done = 0
    @logger.info("Running Linter on #{name}...")
    organization = repo['full_name'].split('/').first
    repo_key = repo['repo_key']
    loop do
      json_return = http_get(agent, "#{host}/api/gitlog/linters_todo?repo_key=#{repo_key}", auth_headers)
      metrics = json_return['metrics']
      all_lints_finished = total_lints_done >= total_lints_count
      break if metrics.empty? || all_lints_finished
      linters = json_return['linters']
      metrics.each do |metric|
        commit = metric['commit']
        checkout_commit(git_dir, commit)
        remove_open_source_files(git_dir)
        Dir.mktmpdir do |dir_name|
          linters.each do |linter|
            ext = linter['output_format']
            cd_first = linter['cd_first']
            quality_tool = linter['quality_tool']
            quality_command = linter['quality_command']

            proj_filename = nil

            file_name = File.join(dir_name, "#{quality_tool}.#{ext}")
            cmd = quality_command.gsub('git_dir', git_dir).gsub('file_name', file_name).gsub('proj_filename', proj_filename.to_s).gsub(/~\/phpcs\/scripts\/phpcs/, "#{File.expand_path("~/phpcs/scripts/phpcs")}")
            # cmd = get_cmd("cd #{git_dir};#{cmd}") if cd_first
            cmd = "cd #{git_dir} && #{cmd}" if cd_first
            puts "\tRunning linter: #{quality_tool}... This may take a while... (#{total_lints_done + 1} / #{total_lints_count})".blue
            @logger.info("Running #{quality_tool} on #{commit}...")
            begin
              `#{cmd}`
              lint_output = File.open(file_name, 'r').read
              scrubber = SourceScrubber.new
              puts "\tUploading lint results to AWS...".blue
              key = "#{organization}_#{name}_#{commit}_#{quality_tool}.#{ext}"
              upload_to_aws('bliss-collector-files', key, scrubber.scrub(lint_output))
              lint_payload = { commit: commit, repo_key: repo_key, linter_id: linter['id'], lint_file_location: key, git_dir: git_dir, bucket: 'bliss-collector-files' }

              lint_response = http_post(agent, "#{host}/api/commit/lint", lint_payload, auth_headers)
            rescue Errno::ENOENT
              puts "#{quality_tool} is not installed. Please refer to the docs at https://github.com/founderbliss/collector to ensure all dependencies are installed.".red
              @logger.info("Dependency Error: #{quality_tool} not installed...")
            end
            total_lints_done += 1
            percent_done = ((total_lints_done.to_f / total_lints_count.to_f) * 100).round(2) rescue 100
            puts "\n\n Finished #{total_lints_done} of #{total_lints_count} lint tasks (#{percent_done}%) for #{name.upcase} \n\n".green
          end
        end
        # Go back to master at the end
        checkout_commit(git_dir, 'master')
      end
    end
    @logger.success("Linter finished for #{name}...")
    @logger.save_log
  end
end
