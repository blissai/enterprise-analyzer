# Stats class for collecting git LOC and other stats
class StatsTask
  include Common
  include Gitbase

  def initialize(git_dir, api_key, host, repo, quick = false)
    init_configuration(git_dir, api_key, host, repo, quick)
    configure_http
    @logger = BlissLogger.new("Stats-#{Time.now.strftime("%d-%m-%y-T%H-%M")}-#{@name}")
    @repo_test_files = @repo['test_files_match'] || %w(test spec)
    @repo_test_dirs = @repo['test_dirs_match'] || %w(test)
    @excluded_dirs = @repo['excluded_directories'] || []
  end

  def execute
    @logger.info("Running Stats on #{@name}...")
    metrics = next_batch
    @logger.info("Processing Stats between #{metrics.last.commited_at} and #{metrics.first.commited_at}") unless metrics.empty?
    metrics.each do |metric|
      commit = metric['commit']
      process_commit(commit)
    end
    # Go back to master at the end
    checkout_commit(@git_dir, @repo['branch'])
    @logger.success("Stats finished for #{@name}")
    @logger.save_log
  end

  def next_batch
    url = "#{@host}/api/gitlog/stats_todo?repo_key=#{@repo_key}"
    url = "#{url}&batch=2" if @quick
    json_return = http_get(url)
    json_return
  end

  def process_commit(commit)
    stats = git_stats(commit)
    checkout_commit(@git_dir, commit)
    all_stats = {
      repo_key: @repo_key, commit: commit,
      added_lines: stats[:added_lines], deleted_lines: stats[:deleted_lines],
      total_cloc: cloc_total, cloc: cloc_original, cloc_tests: cloc_tests
    }
    post_stats(all_stats)
  end

  def post_stats(stats)
    @logger.info("\tPosting commit stats to Bliss...")
    stats_response = http_post("#{@host}/api/commit/stats", stats)
    return if stats_response.nil?
    @logger.success("\tSuccessfully saved stats for commit #{stats[:commit]}.")
  end

  def cloc_total
    @logger.info("\tCounting total lines of code. This may take a while...")
    `#{cloc_cmd}`
  end

  def cloc_original
    remove_open_source_files(@git_dir)
    remove_excluded_directories(@excluded_dirs, @git_dir)
    @logger.info("\tCounting original lines of code. This may take a while...")
    `#{cloc_cmd}`
  end

  def cloc_cmd
    "perl #{cloc_command} #{@git_dir} #{cloc_options}"
  end

  def cloc_tests
    @logger.info("\tCounting lines of test code. This may take a while...")
    test_dirs = get_test_dirs(@git_dir, @repo_test_files, @repo_test_dirs)
    if !test_dirs.empty?
      cmd = "perl #{cloc_command} #{test_dirs} #{cloc_options}"
      cloc_tests = `#{cmd}`
    else
      @logger.warn("\tNo known test pattern for cloc to run - skipped")
      cloc_tests = nil
    end
    cloc_tests
  end

  def git_numstat(commit)
    stats = `cd #{@git_dir} && git log --pretty=tformat: --numstat #{commit}`
    stats.split("\n")
  end

  def git_stats(commit)
    @logger.info("Getting stats for #{commit}...")
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
