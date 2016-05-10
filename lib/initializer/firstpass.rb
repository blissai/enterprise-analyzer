class FirstPass
  include Linter
  include Stats
  include Initializer
  include Gitlogger
  include Common

  def initialize(subdir = nil)
    @git_dir = '/repository'
    @subdir = subdir
    @directory_to_analyze = @subdir.nil? ? @git_dir : File.join(@git_dir, @subdir)
    @api_key = ENV['API_KEY']
    @host = ENV['BLISS_HOST']
    @org_name = ENV['ORG_NAME']
    configure_http
    @logger = BlissLogger.new(@api_key)
    @scrubber = SourceScrubber.new
  end

  def execute
    bliss_initialize
    gitlogger
    stats
    linting
    result = post_to_bliss
    checkout_commit(@git_dir, @repo['branch'])
    if result[:error]
      @logger.error(result[:error])
    elsif result[:success]
      @logger.success('Finished! We will send you an email once we have analyzed your data.')
    end
  end

  def bliss_initialize
    @logger.info('Initializating Bliss Project...')
    @repo = initialize_bliss_repository(@git_dir, @org_name, @subdir)
    @repo_key = @repo['repo_key']
    @name = @repo['name']
    @repo_test_files = @repo['test_files_match'] || %w(test spec)
    @repo_test_dirs = @repo['test_dirs_match'] || %w(test)
    @excluded_dirs = @repo['excluded_directories'] || []
  end

  def post_to_bliss
    @logger.info("\tUploading repository data to Bliss...")
    data = {
      repo_key: @repo['repo_key'],
      init_data: @commits
    }
    json_return = http_post("#{@host}/api/repo/initialize", data, true)
    if json_return['error']
      return { error: json_return['error'] }
    elsif json_return['success']
      return { success: json_return['success'] }
    end
  end

  def gitlogger
    @logs = first_commits
  end

  def stats
    @commits = {}
    @logs.each do |log|
      commit_hash = log.split('|').first
      @commit = commit_hash
      @commits[log] = { stats: execute_stats_cmd(commit_hash, @directory_to_analyze) }
    end
  end

  def linting
    @logger.info("#{@name} - Running Linters...")
    @linters = http_get("#{@host}/api/repo/linters?repo_key=#{@repo_key}")
    @logs.each do |log|
      @commit = log.split('|').first
      @logger.info("#{@name} - Running Linters on #{@commit}...")
      checkout_commit(@git_dir, @commit)
      remove_open_source_files(@directory_to_analyze) unless @repo['detect_open_source'] == false
      remove_excluded_directories(@excluded_dirs, @directory_to_analyze)
      remove_symlinks(@directory_to_analyze)
      @commits[log]['lint_files'] = []
      @linters.each do |linter|
        tmpfile_path = File.expand_path("~/bliss/#{@repo['name']}-#{@commit}-#{linter['name']}.#{linter['output_format']}")
        File.write(tmpfile_path, 'failtorundocker')
        @output_file = tmpfile_path
        partition_and_lint(linter, @directory_to_analyze)
        ext = linter['output_format']
        key = "#{@org_name}_#{@repo['name']}_#{@commit}_#{linter['quality_tool']}.#{ext}"
        post_lintfile_to_aws(key, File.read(@output_file))
        @commits[log]['lint_files'].push(
          linter_id:  linter['id'],
          lint_file_location: key,
          git_dir: @git_dir,
          bucket: 'bliss-collector-files'
        )
      end
    end
  end

  private

  def first_commits(limit = 1)
    logs = collect_logs(@git_dir, @repo['branch'], limit)
    logs.split("\n").select do |l|
      !l.start_with?(' ') && !l.empty?
    end.reverse
  end
end
