class LocalGitlogger
  include Gitlogger
  def initialize(git_dir, branch = nil, fork_url = nil)
    @git_dir = git_dir.nil? ? '/repository' : File.expand_path(git_dir)
    @branch = branch
    @fork_url = fork_url
  end

  def execute
    fetch_fork(@fork_url) unless @fork_url.nil?
    puts collect_logs(@git_dir, @branch)
  end
end
