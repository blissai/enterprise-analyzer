class LocalLinter
  include Common
  include Gitbase
  include Linter

  def initialize(git_dir, commit, log_prefix, linter_config_path, output_file)
    @logger = BlissLogger.new
    @git_dir = git_dir.nil? ? '/repository' : File.expand_path(git_dir)
    unless File.exist? @git_dir
      puts 'Directory does not exist.'
      exit 1
    end
    @linter_config_path = linter_config_path.nil? ? '/linter.yml' : File.expand_path(linter_config_path)
    unless File.exist? @linter_config_path
      puts 'Linter config file does not exist.'
      exit 1
    end

    @commit = commit
    @name = log_prefix
    @linter = YAML::load_file(@linter_config_path)
    @output_file = output_file
    @api_key = nil
    @repo_key = nil
  end

  def execute
    lint_commit(@commit, @linter, @output_file, false)
  end
end
