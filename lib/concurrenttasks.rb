class ConcurrentTasks
  include Common
  include Gitbase
  def initialize(config)
    @top_level_dir = config['TOP_LVL_DIR']
    @org_name = config['ORG_NAME']
    @api_key = config['API_KEY']
    @bliss_host = config['BLISS_HOST']
    @repos = read_bliss_file(@top_level_dir)
    @dirs_list = get_directory_list(@top_level_dir)
  end

  def stats
    threads = []
    @dirs_list.each do |git_dir|
      name = extract_name_from_git_url(git_dir)
      threads << Thread.new(git_dir, @api_key, @bliss_host, @repos[name]) do |dir, key, host, repo|
        StatsTask.new(dir, key, host, repo).execute
      end
    end
    threads.each(&:join)
    puts 'Stats finished.'
  end

  def linter
    threads = []
    @dirs_list.each do |git_dir|
      name = extract_name_from_git_url(git_dir)
      threads << Thread.new(git_dir, @api_key, @bliss_host, @repos[name]) do |dir, key, host, repo|
        LinterTask.new(dir, key, host, repo).execute
      end
    end
    threads.each(&:join)
    puts 'Lints finished.'
  end
end
