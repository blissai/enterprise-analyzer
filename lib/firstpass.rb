class FirstPass
  include Linter
  include Stats
  include Initializer
  include Gitlogger
  include Common
  include AwsUploader

  def initialize(subdir)
    @git_dir = '/repository'
    @subdir = subdir
    @directory_to_analyze = File.join(@git_dir, @subdir)
    @api_key = ENV['API_KEY']
    @bliss_host = ENV['BLISS_HOST']
    @org_name = ENV['ORG_NAME']
    configure_http
    @logger = BlissLogger.new(@api_key)
  end

  def execute
    bliss_initialize
    gitlogger
    stats
    linting
    @logger.success('Finished! We will send you an email once we have analyzed your data.')
  end

  def bliss_initialize
    @logger.info('Initialization Bliss Project...')
    @repository = initialize_bliss_repository(@git_dir, @org_name, @subdir)
    remove_open_source_files(@git_dir)
    remove_excluded_directories(@repository['excluded_directories'])
    remove_symlinks(@git_dir)
  end

  def gitlogger
    @log = first_commits
  end

  def stats
    @commits = {}
    @logs.each do |log|
      commit_hash = log.split('|').first
      @commits[log] = { stats: execute_stats_cmd(commit_hash) }
    end
  end

  def linting
    @linters = http_get("#{@host}/api/repo/linters", repo_key: repository['repo_key'])
    @logs.each do |log|
      commit_hash = log.split('|').first
      checkout_commit(@git_dir, commit_hash)
      @commits[log]['lint_files'] = []
      @linters.each do |linter|
        tmpfile_path = File.expand_path("~/bliss/#{@repository['name']}-#{commit_hash}-#{linter['name']}.#{linter['output_format']}")
        File.write(tmpfile_path, 'failtorundocker')
        lint_commit(linter, tmpfile_path, false, @directory_to_analyze)
        key = "#{@repository['name']}-#{commit_hash}-#{linter['name']}"
        upload_to_aws('bliss-collector-files', key, File.read(tmpfile_path))
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

  def first_commits(limit = 2)
    logs = collect_logs(@git_dir, @repository['name'],
                        @repository['branch'], limit)
    logs.split("\n").select do |l|
      !l.start_with?(' ') && !l.empty?
    end.reverse
  end
end
