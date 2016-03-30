class LocalGitlogger
  include Gitlogger
  def initialize(git_dir, log_prefix, branch = nil)
    @git_dir = git_dir.nil? ? '/repository' : File.expand_path(git_dir)
    @name = log_prefix
    @branch = branch
  end

  def execute
    puts collect_logs(@git_dir, @name, @branch)
  end
end
