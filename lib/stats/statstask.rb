# Stats class for collecting git LOC and other stats
class StatsTask
  include Stats
  include Common
  include Gitbase
  include Daemon

  def initialize(git_dir, api_key, repo)
    init_configuration(git_dir, api_key, repo)
    configure_http
    @logger = BlissLogger.new(api_key, @repo_key, @name)
    @repo_test_files = @repo['test_files_match'] || %w(test spec)
    @repo_test_dirs = @repo['test_dirs_match'] || %w(test)
    @excluded_dirs = @repo['excluded_directories'] || []
    @repo_excluded_exts = @repo['excluded_exts'] || []
  end

  def execute
    @logger.info("Running Stats...")
    metrics = next_batch
    unless metrics.empty?
      starttime = DateTime.parse(metrics.last['commited_at'])
      endtime = DateTime.parse(metrics.first['commited_at'])
      dates = "#{starttime.strftime('%d-%m-%Y')} and #{endtime.strftime('%d-%m-%Y')}"
      @logger.success("Processing Stats between #{dates}")
    end
    metrics.each do |metric|
      break if stop_daemon?
      @commit = metric['commit']
      result = process_commit(@commit)
      @logger.success("\tFinished stats for commit #{@commit}.") unless result.nil?
    end
    # Go back to master at the end
    checkout_commit(@git_dir, @repo['branch'])
    @logger.success('Stats finished.')
  end

  def next_batch
    url = "#{@host}/api/gitlog/stats_todo?repo_key=#{@repo_key}"
    json_return = http_get(url)
    json_return
  end

  def process_commit(commit)
    all_stats = execute_stats_cmd(commit)
    post_stats(all_stats)
  end
end
