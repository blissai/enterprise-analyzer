class LocalLinter
  include Common
  include Gitbase
  include Linter

  def initialize(git_dir, commit, log_prefix, linter_config_path)
    @logger = BlissLogger.new
    @git_dir = git_dir.nil? ? '/repository' : File.expand_path(git_dir)
    @linter_config_path = linter_config_path.nil? ? '/linter.yml' : File.expand_path(linter_config_path)
    @commit = commit
    @name = log_prefix
    @linter = YAML::load_file(@linter_config_path)
    @output_file = '/result.txt'
    @api_key = nil
    @repo_key = nil
    check_args
  end

  def execute
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
    elsif !File.exist? @linter_config_path
      puts 'Linter config file does not exist.'
      valid = false
    elsif @commit.nil? || @commit.empty?
      puts 'Please specify a commit.'
      valid = false
    end
    exit 1 unless valid
  end
end
