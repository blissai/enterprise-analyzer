# Collector class for collecting git LOC and other stats
class CollectorTask
  include Common
  include Gitbase
  include AwsUploader

  def initialize(config)
    @top_lvl_dir = config['TOP_LVL_DIR']
    @org_name = config['ORG_NAME']
    @api_key = config['API_KEY']
    @host = config['BLISS_HOST']
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

  def git_log(dir_name)
    log_fmt = '"%H|%P|%ai|%aN|%aE|%s"'
    cmd = "cd #{dir_name} && git log --all --pretty=format:#{log_fmt}"
    `#{cmd}`
  end

  def prepare_log(name, lines)
    @logger.info("\tSaving repo data to AWS Bucket...")
    key = "#{@org_name}_#{name}_git.log"
    upload_to_aws('bliss-collector-files', key, lines)
    key
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
    name = dir_name.split('/').last
    puts "Working on: #{name}...".blue
    repo_details = save_repository_to_bliss(dir_name, name)
    puts "\tCreated repo ##{repo_details['id']} - #{repo_details['full_name']}".green
    @repos[name] = repo_details
    checkout_commit(dir_name, @repos[name]['branch'])
    @logger.info("\tGetting gitlog for #{name}")
    lines = git_log(dir_name)
    @repos[name]['commit_count'] = lines.split("\n").count
    @logger.info("\t#{@repos[name]['commit_count']} commits found...")
    repo_key = @repos[name]['repo_key']
    if needs_running? name, @repos[name]['commit_count']
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

  def git_url(dir_name)
    git_base_cmd = "cd #{dir_name} && git config --get remote.origin.url"
    url = `#{git_base_cmd}`
    if url.empty?
      svn_base_cmd = "cd #{dir_name} && git svn info | grep URL | cut -f2- -d' '"
      url = `#{svn_base_cmd}`
    end
    url.chomp
  end

  def save_git_log(name, lines, repo_key)
    @logger.info("\tSaving Gitlog to AWS...")
    s3_object_key = prepare_log(name, lines)
    http_post("#{@host}/api/gitlog",   repo_key: repo_key,
                                       object_key: s3_object_key,
                                       bucket: 'bliss-collector-files')
  end

  def needs_running?(repo_name, commit_count)
    return (new_repo? repo_name) || (@saved_repos[repo_name]['commit_count'] < commit_count)
  rescue
    return true
  end

  def new_repo?(repo_name)
    !@saved_repos.key? repo_name
  end
end
