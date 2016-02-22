module Stats
  def execute_stats_cmd(commit, remote = false)
    stats = git_stats(commit)
    checkout_commit(@git_dir, commit)
    all_stats = {
      commit: commit,
      added_lines: stats[:added_lines], deleted_lines: stats[:deleted_lines],
      total_cloc: cloc_total, cloc: cloc_original, cloc_tests: cloc_tests
    }
    post_stats(all_stats) if remote
    all_stats
  end

  def post_stats(stats)
    @logger.info("\t#{@name} - Posting commit stats to Bliss...")
    stats[:repo_key] = @repo_key
    stats_response = http_post("#{@host}/api/commit/stats", stats)
    return if stats_response.nil?
    @logger.success("\t#{@name} - Successfully saved stats for commit #{stats[:commit]}.")
  end

  def cloc_total
    @logger.info("\t#{@name} - Counting total lines of code. This may take a while...")
    `#{cloc_cmd}`
  end

  def cloc_original
    remove_open_source_files(@git_dir) unless @repo['detect_open_source'] == false
    remove_excluded_directories(@excluded_dirs, @git_dir)
    @logger.info("\t#{@name} - Counting original lines of code. This may take a while...")
    `#{cloc_cmd}`
  end

  def cloc_cmd
    "perl #{cloc_command} #{@git_dir} #{cloc_options}"
  end

  def cloc_tests
    @logger.info("\t#{@name} - Counting lines of test code. This may take a while...")
    test_dirs = get_test_dirs(@git_dir, @repo_test_files, @repo_test_dirs)
    if !test_dirs.empty?
      cmd = "perl #{cloc_command} #{test_dirs} #{cloc_options}"
      cloc_tests = `#{cmd}`
    else
      @logger.warn("\t#{@name} - No known test pattern for cloc to run - skipped")
      cloc_tests = nil
    end
    cloc_tests
  end

  def git_numstat(commit)
    stats = `cd #{@git_dir} && git log --pretty=tformat: --numstat #{commit}`
    stats.split("\n")
  end

  def git_stats(commit)
    @logger.info("#{@name} - Getting stats for #{commit}...")
    added_lines = 0
    deleted_lines = 0
    git_numstat(commit).each do |stt|
      match = stt.match(/(\d+)\t(\d+)/)
      next unless match
      added_lines += match[1].to_i
      deleted_lines += match[2].to_i
    end
    { added_lines: added_lines, deleted_lines: deleted_lines }
  end
end
