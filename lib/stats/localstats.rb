class LocalStats
  include Gitbase
  include Stats

  def initialize(git_dir, commit, log_prefix,
                 excluded_dirs, repo_test_files, repo_test_dirs, remove_open_source)
    puts git_dir
    puts commit
    puts log_prefix
    @logger = BlissLogger.new
    @commit = commit
    @git_dir = git_dir.nil? ? '/repository' : File.expand_path(git_dir)
    unless File.exist? @git_dir
      puts 'Directory does not exist.'
      exit 1
    end
    @name = log_prefix
    @excluded_dirs = excluded_dirs.split(',') rescue []
    @repo_test_files = repo_test_files.split(',') rescue []
    @repo_test_dirs = repo_test_dirs.split(',') rescue []
    @api_key = nil
    @repo_key = nil
    @repo = { 'remove_open_source' => remove_open_source }
  end

  def execute
    execute_stats_cmd(@commit, false).to_yaml
  end
end
