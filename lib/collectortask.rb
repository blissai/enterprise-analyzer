# Collector class for collecting git LOC and other stats
class CollectorTask
  include Common
  include Gitbase
  include Gitlogger

  def initialize(config)
    @top_lvl_dir = config['TOP_LVL_DIR']
    @org_name = config['ORG_NAME']
    @api_key = config['API_KEY']
    @host = ENV['BLISS_HOST']
    @logger = BlissLogger.new(@api_key)
    @logger.info('Starting Collector...')
    @saved_repos = begin
                     read_bliss_file(@top_lvl_dir)
                   rescue
                     {}
                   end
    configure_http
    @new_repos = false
    @stats_todo = 0
    @linters_todo = 0
  end

  def configure_branch(repo_dir)
    branches = `cd #{repo_dir} && git branch`.split("\n").map(&:strip)
    branch = branches.find { |b| b.start_with? '* ' }
    branch.sub(/\* /, '')
  end

  def execute
    @repos = {}
    dir_list = get_directory_list(@top_lvl_dir)
    @logger.success("Found #{dir_list.count} repositories...")
    if dir_list.empty?
      puts 'Please check your top level directory configuration is correct.'.red
      puts 'You can find this configuration in $HOME/.bliss/config.yml'.red
    end
    dir_list.each do |dir_name|
      process_repo(dir_name)
    end
    save_bliss_file(@top_lvl_dir, @repos)
    @logger.success('Collector finished...')
    { 'new_repos' => @new_repos, 'stats_todo' => @stats_todo, 'linters_todo' => @linters_todo }
  end

  def process_repo(dir_name)
    name = extract_name_from_git_url(dir_name)
    puts "Working on: #{name}...".blue
    repo_details = save_repository_to_bliss(dir_name, name)
    puts "\tCreated repo ##{repo_details['id']} - #{repo_details['full_name']}".green
    @repos[name] = repo_details
    checkout_commit(dir_name, @repos[name]['branch'])
    @logger.info("\tGetting history...")
    lines = git_log(dir_name)
    repo_key = @repos[name]['repo_key']
    if needs_running? name, @repos[name]['gitlog_checksum']
      save_git_log(name, lines, repo_key)
    else
      @logger.info("\tNo new commits...")
    end
    puts "\tChecking server for outstanding stats tasks...".blue
    @stats_todo += todo_count(@repos[name]['repo_key'], 'stats')
    puts "\tChecking server for outstanding linting tasks...".blue
    @linters_todo += todo_count(@repos[name]['repo_key'], 'linters')
  end

  def save_repository_to_bliss(dir_name, name)
    git_base = git_url(dir_name)
    git_base = "#{@org_name}/#{name}" if git_base.empty?
    @logger.info("\tSaving repository details to database...")
    params = { name: name, full_name: "#{@org_name}/#{name}",
               git_url: git_base, languages: sense_project_type(dir_name).to_json }
    params[:branch] = configure_branch(dir_name) if new_repo? name
    repo_return = http_post("#{@host}/api/repo.json", params)
    if repo_return.nil?
      @logger.error('Could not connect to Bliss. Please contact us at hello@bliss.ai for support.')
      exit
    end
    @new_repos = new_repo?(name) unless @new_repos
    repo_return
  end

  def needs_running?(repo_name, gitlog_checksum)
    return (new_repo? repo_name) || (@saved_repos[repo_name]['gitlog_checksum'] != gitlog_checksum)
  rescue
    return true
  end

  def new_repo?(repo_name)
    !@saved_repos.key? repo_name
  end
end
