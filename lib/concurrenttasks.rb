class ConcurrentTasks
  include Common
  def initialize config
    @top_level_dir = config['TOP_LVL_DIR']
    @org_name = config['ORG_NAME']
    @api_key = config['API_KEY']
    @bliss_host = config['BLISS_HOST']
    @dirs_list = get_directory_list(@top_level_dir)
  end

  def stats
    threads = []
    @repos = read_bliss_file(@top_level_dir)
    @dirs_list.each do |git_dir|
      name = git_dir.split('/').last
      threads << Thread.new(git_dir, @api_key, @bliss_host, @repos[name]) { |dir, key, host, repo|
        StatsTask.new.execute(dir, key, host, repo)
      }
    end
    threads.each do |thr|
      thr.join
    end
    puts "Stats finished."
  end

  def linter
    threads = []
    @repos = read_bliss_file(@top_level_dir)
    @dirs_list.each do |git_dir|
      name = git_dir.split('/').last
      threads << Thread.new(git_dir, @api_key, @bliss_host, @repos[name]) { |dir, key, host, repo|
        LinterTask.new.execute(dir, key, host, repo)
      }
    end
    threads.each do |thr|
      thr.join
    end
    puts "Lints finished."
  end

end
