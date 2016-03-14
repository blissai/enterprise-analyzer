# Stats class for collecting git LOC and other stats
class LinterTask
  include Linter
  include Common
  include Gitbase
  include AwsUploader

  def initialize(git_dir, api_key, host, repo)
    init_configuration(git_dir, api_key, host, repo)
    configure_http
    @logger = BlissLogger.new(api_key, @repo_key, @name)
    @scrubber = SourceScrubber.new
    @from_date = nil
    @to_date = nil
    @excluded_dirs = @repo['excluded_directories'] || []
  end

  def execute
    @logger.info('Running Linter...')
    metrics = next_batch
    unless metrics.empty?
      starttime = DateTime.parse(metrics.last['commited_at'])
      endtime = DateTime.parse(metrics.first['commited_at'])
      dates = "#{starttime.strftime('%d-%m-%Y')} and #{endtime.strftime('%d-%m-%Y')}"
      @logger.success("Processing Linters between #{dates}")
    end
    metrics.each do |metric|
      commit = metric['commit']
      @logger.success("Running linters over #{commit}")
      process_commit(commit)
    end
    # Go back to main branch
    checkout_commit(@git_dir, @repo['branch'])
    @logger.success('Linter finished...')
  end

  def process_commit(commit)
    checkout_commit(@git_dir, commit)
    remove_open_source_files(@git_dir) unless @repo['detect_open_source'] == false
    remove_excluded_directories(@excluded_dirs, @git_dir)
    remove_symlinks(@git_dir)
    Dir.mktmpdir do |tmp_dir|
      @linters.each do |linter|
        @output_file = File.join(tmp_dir, "#{linter['quality_tool']}.#{linter['output_format']}")
        @commit = commit
        partition_and_lint(linter, true)
        # lint_commit(linter, output_file, true)
      end
    end
    @logger.success("\tFinished linting for commit #{commit}")
  end

  private

  def next_batch
    url = "#{@host}/api/gitlog/linters_todo?repo_key=#{@repo_key}"
    json_return = http_get(url)
    @linters = json_return['linters']
    json_return['metrics']
  end
end
