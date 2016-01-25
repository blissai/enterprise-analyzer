class ConcurrentTasks
  include Common
  def initialize(config, quick = false)
    @top_level_dir = config['TOP_LVL_DIR']
    @org_name = config['ORG_NAME']
    @api_key = config['API_KEY']
    @bliss_host = config['BLISS_HOST']
    @repos = read_bliss_file(@top_level_dir)
    @dirs_list = get_directory_list(@top_level_dir)
    @quick = quick
  end

  def stats
    threads = []
    @dirs_list.each do |git_dir|
      name = git_dir.split('/').last
      threads << Thread.new(git_dir, @api_key, @bliss_host, @repos[name], @quick) do |dir, key, host, repo, quick|
        StatsTask.new(dir, key, host, repo, quick).execute
      end
    end
    threads.each(&:join)
    puts 'Stats finished.'
  end

  def linter
    threads = []
    @dirs_list.each do |git_dir|
      name = git_dir.split('/').last
      threads << Thread.new(git_dir, @api_key, @bliss_host, @repos[name], @quick) do |dir, key, host, repo, quick|
        LinterTask.new(dir, key, host, repo, quick).execute
      end
    end
    threads.each(&:join)
    puts 'Lints finished.'
  end
end
