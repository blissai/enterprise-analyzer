class LocalStats
  include Gitbase
  include Stats

  def initialize(git_dir, commit, log_prefix,
                 excluded_dirs, repo_test_files, repo_test_dirs, remove_open_source = true)
    @logger = BlissLogger.new
    @commit = commit
    @git_dir = git_dir.nil? ? '/repository' : File.expand_path(git_dir)
    @output_file = '/result.txt'
    @name = log_prefix
    @excluded_dirs = excluded_dirs.split(',') rescue []
    @repo_test_files = repo_test_files.split(',') rescue %w(test)
    @repo_test_dirs = repo_test_dirs.split(',') rescue %w(test spec)
    @api_key = nil
    @repo_key = nil
    @repo = { 'detect_open_source' => remove_open_source }
    check_args
  end

  def execute
    File.write(@output_file, execute_stats_cmd(@commit).to_json)
  end

  def check_args
    valid = true
    if !File.exist? @git_dir
      @logger.error("#{@name} - Directory does not exist.")
      valid = false
    elsif @output_file.nil? || !File.exist?(@output_file)
      @logger.error("#{@name} - Please specify a writable file to output to.")
      valid = false
    elsif File.directory?(@output_file)
      @logger.error("#{@name} - Output file is a directory. Should be a file.")
      valid = false
    elsif @commit.nil? || @commit.empty?
      @logger.error("#{@name} - Please specify a commit.")
      valid = false
    end
    exit 1 unless valid
  end
end
