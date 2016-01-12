# Stats class for collecting git LOC and other stats
class StatsTask
  include Common
  include Gitbase

  def execute(git_dir, api_key, host, repo)
    name = git_dir.split('/').last
    @logger = BlissLogger.new("Stats-#{Time.now.strftime("%d-%m-%y-T%H-%M")}-#{name}")
    @logger.info("Starting Stats on #{name}...")
    agent = Mechanize.new
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    auth_headers = { 'X-User-Token' => api_key }
    # Count number of commits to process in total
    total_commits_count = 0
    repo_key = repo['repo_key']
    repo_test_files = repo['test_files_match'] || %w(test spec)
    repo_test_dirs = repo['test_dirs_match'] || %w(test)
    count_json = http_get(agent, "#{host}/api/gitlog/stats_todo_count?repo_key=#{repo_key}", auth_headers)
    count = count_json["stats_todo"].to_i
    total_commits_count += count
    total_commits_done = 0
    json_return = []
    loop do
      json_return = http_get(agent, "#{host}/api/gitlog/stats_todo?repo_key=#{repo_key}", auth_headers)
      all_commits_processed = total_commits_done >= total_commits_count
      break if json_return.nil? || json_return.empty? || all_commits_processed
      @logger.info("Running Stats on #{name}...")
      json_return.each do |metric|
        commit = metric['commit']
        @logger.info("Getting stats for #{commit}... (#{total_commits_done + 1} / #{total_commits_count})")
        stat_command = "git log --pretty=tformat: --numstat #{commit}"
        # cmd = get_cmd("cd #{git_dir}; #{stat_command}")
        cmd = "cd #{git_dir} && #{stat_command}"
        # puts "\t\t#{cmd}"
        added_lines = 0
        deleted_lines = 0
        @stats = %x{#{cmd}}
        @stats.split("\n").each do |stt|
          match = stt.match(/(\d+)\t(\d+)/)
          if match
            added_lines += match[1].to_i
            deleted_lines += match[2].to_i
          end
        end
        checkout_commit(git_dir, commit)
        language = sense_project_type(git_dir)
        cmd = "perl #{cloc_command} #{git_dir} #{cloc_options}"
        @logger.info("\tCounting total lines of code. This may take a while... (#{total_commits_done + 1} / #{total_commits_count})")

        begin
          total_cloc = `#{cmd}`
        rescue Errno::ENOENT
          @logger.error("Perl is not installed! Please refer to the docs at https://github.com/founderbliss/collector to ensure all dependencies are installed.")
          exit
        end

        remove_open_source_files(git_dir)
        cmd = "perl #{cloc_command} #{git_dir} #{cloc_options}"
        @logger.info("\tCounting original lines of code. This may take a while... (#{total_commits_done + 1} / #{total_commits_count})")
        cloc = `#{cmd}`

        @logger.info("\tCounting lines of test code. This may take a while... (#{total_commits_done + 1} / #{total_commits_count})")
        cloc_test_dirs = get_test_dirs(git_dir, repo_test_files, repo_test_dirs)
        if !cloc_test_dirs.empty?
          cmd = "perl #{cloc_command} #{cloc_test_dirs} #{cloc_options}"
          cloc_tests = `#{cmd}`
        else
          @logger.warn("\tNo known test pattern for cloc to run - skipped")
        end
        stat_payload = {
          repo_key: repo_key,
          commit: commit,
          added_lines: added_lines,
          deleted_lines: deleted_lines,
          total_cloc: total_cloc,
          cloc: cloc,
          cloc_tests: cloc_tests
        }
        @logger.info("\tPosting commit stats to Bliss... (#{total_commits_done + 1} / #{total_commits_count})")
        stats_response = http_post(agent, "#{host}/api/commit/stats", stat_payload, auth_headers)
        break if stats_response.nil?
        @logger.success("\tSuccessfully saved stats for commit #{commit}. (#{total_commits_done + 1} / #{total_commits_count})")
        # puts "\t\tstats_response: #{stats_response.inspect}"
        total_commits_done += 1
        percent_done = ((total_commits_done.to_f / total_commits_count.to_f) * 100).round(2) rescue 100
        @logger.success("\n\n Finished #{total_commits_done} of #{total_commits_count} stats tasks (#{percent_done}%) for #{name.upcase} \n\n")
      end
    end
    # Go back to master at the end
    checkout_commit(git_dir, 'master')
    @logger.success("Stats finished for #{name}")
    @logger.save_log
  end
end
