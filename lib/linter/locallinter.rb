class LocalLinter
  include Common
  include Gitbase
  include Linter

  def initialize(git_dir, commit, log_prefix, linter_config_path, excluded_dirs)
    @logger = BlissLogger.new
    @git_dir = git_dir.nil? ? '/repository' : File.expand_path(git_dir)
    @linter_config_path = linter_config_path.nil? ? '/linter.yml' : File.expand_path(linter_config_path)
    @commit = commit
    @name = log_prefix
    @linter = YAML::load_file(@linter_config_path)
    @excluded_dirs = excluded_dirs.split(',') rescue []
    @output_file = '/result.txt'
    @api_key = nil
    @repo_key = nil
    check_args
  end

  def execute
    remove_excluded_directories(@excluded_dirs, @git_dir)
    lint_commit(@commit, @linter, @output_file, false)
  end

  def check_args
    valid = true
    if !File.exist? @git_dir
      puts 'Directory does not exist.'
      valid = false
    elsif @output_file.nil? || !File.exist?(@output_file)
      puts 'Please specify a writable file to output to.'
      valid = false
    elsif File.directory?(@output_file)
      puts 'Output file is a directory. Should be a file.'
      valid = false
    elsif @linter_config_path.nil? || !File.exist?(@linter_config_path)
      puts 'Linter config file does not exist.'
      valid = false
    elsif File.directory?(@linter_config_path)
      puts 'Linter config path is a directory. Should be a file.'
      valid = false
    elsif @commit.nil? || @commit.empty?
      puts 'Please specify a commit.'
      valid = false
    end
    exit 1 unless valid
  end
end
