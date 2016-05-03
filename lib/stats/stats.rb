module Stats
  STATS_DEFAULT_THRESHOLD = 104_857_600
  def execute_stats_cmd(commit, directory = nil)
    stats = git_stats(commit)
    checkout_commit(@git_dir, commit)
    directory = @git_dir if directory.nil?
    all_stats = {
      commit: commit,
      added_lines: stats[:added_lines], deleted_lines: stats[:deleted_lines]
    }
    all_stats.merge(partition_and_stats(directory))
  end

  def partition_and_stats(directory = nil)
    directory_to_analyze = directory.nil? ? @git_dir : directory
    parts = Partitioner.new(directory_to_analyze, @logger, { 'partitionable' => true }, STATS_DEFAULT_THRESHOLD).create_partitions
    @logger.info("\tRunning Stats on #{@commit}... This may take a while...")
    @logger.info("\tCounting total, original and test lines of code...")
    num_proc = parts.size
    num_proc = 4 if num_proc > 4
    clocs = Parallel.map(parts, in_processes: num_proc) do |part|
      c = cloc_total(part)
      oc = cloc_original(part)
      tc = cloc_tests(part)
      {
        total_cloc: c,
        cloc: oc,
        cloc_tests: tc
      }
    end
    consolidate_clocs(clocs)
  end

  def consolidate_clocs(clocs)
    total_clocs = clocs.map { |c| c[:total_cloc] }
    original_clocs = clocs.map { |c| c[:cloc] }
    test_clocs = clocs.map { |c| c[:cloc_tests] }
    sm = StatsMerger.new(total_clocs)
    total_clocs = sm.merge_files.to_yaml
    sm.update_clocs(original_clocs)
    original_clocs = sm.merge_files.to_yaml
    sm.update_clocs(test_clocs)
    test_clocs = sm.merge_files.to_yaml
    { total_cloc: total_clocs, cloc: original_clocs, cloc_tests: test_clocs }
  end

  def post_stats(stats)
    stats[:repo_key] = @repo_key
    http_post("#{@host}/api/commit/stats", stats)
  end

  def cloc_total(directory)
    `#{cloc_cmd(directory)}`
  end

  def cloc_original(directory)
    remove_open_source_files(directory) unless @repo['detect_open_source'] == false
    remove_excluded_directories(@excluded_dirs, directory)
    `#{cloc_cmd(directory)}`
  end

  def cloc_cmd(directory)
    "perl #{cloc_command} #{directory} #{cloc_options(@repo_excluded_exts)}"
  end

  def cloc_tests(directory)
    test_dirs = get_test_dirs(directory, @repo_test_files, @repo_test_dirs)
    if !test_dirs.empty?
      cmd = "perl #{cloc_command} #{test_dirs} #{cloc_options(@repo_excluded_exts)}"
      cloc_tests = `#{cmd}`
    else
      cloc_tests = nil
    end
    cloc_tests
  end

  def git_numstat(commit)
    stats = `cd #{@git_dir} && git log --pretty=tformat: --numstat #{commit}`
    stats.split("\n")
  end

  def git_stats(commit)
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

  def fill_stats_if_empty(result)
    return result unless result.empty?

  end
end
