# Stats class for collecting git LOC and other stats
class StatsTask
  include Stats
  include Common
  include Gitbase

  def initialize(git_dir, api_key, host, repo)
    init_configuration(git_dir, api_key, host, repo)
    configure_http
    @logger = BlissLogger.new(api_key, @repo_key)
    @repo_test_files = @repo['test_files_match'] || %w(test spec)
    @repo_test_dirs = @repo['test_dirs_match'] || %w(test)
    @excluded_dirs = @repo['excluded_directories'] || []
  end

  def execute
    @logger.info("Running Stats on #{@name}...")
    metrics = next_batch
    unless metrics.empty?
      starttime = DateTime.parse(metrics.last['commited_at'])
      endtime = DateTime.parse(metrics.first['commited_at'])
      dates = "#{starttime.strftime('%d-%m-%Y')} and #{endtime.strftime('%d-%m-%Y')}"
      @logger.success("#{@name} - Processing Stats between #{dates}")
    end
    metrics.each do |metric|
      commit = metric['commit']
      process_commit(commit)
    end
    # Go back to master at the end
    checkout_commit(@git_dir, @repo['branch'])
    @logger.success("Stats finished for #{@name}")
  end

  def next_batch
    url = "#{@host}/api/gitlog/stats_todo?repo_key=#{@repo_key}"
    json_return = http_get(url)
    json_return
  end

  def process_commit(commit)
    execute_stats_cmd(commit, true)
  end
end