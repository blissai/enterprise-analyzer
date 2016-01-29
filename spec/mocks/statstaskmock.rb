class StatsTaskMock < StatsTask
  # don't include spec as git dir is in this spec
  def set_test_dirs
    @repo_test_files = %w(test)
    @repo_test_dirs = %w(test)
  end

  # run cloc from local not docker bin path
  def cloc_command
    'bin/cloc'
  end

  # mocking server calls
  def http_get(_url)
    [{ 'commit' => 'test', 'commited_at' => DateTime.now.to_s }]
  end

  def post_stats(stats)
    stats
  end

  def checkout_commit(git_dir, branch)
  end

  def git_stats(commit)
    { added_lines: 4, deleted_lines: 3 }
  end
end
