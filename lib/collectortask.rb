# Stats class for collecting git LOC and other stats
class CollectorTask
  include Common
  include Gitbase
  include AwsUploader

  def initialize(top_dir_name, organization, api_key, host)
    @logger = BlissLogger.new("Collector-#{Time.now.strftime("%d-%m-%y-T%H-%M")}-#{organization}")
    @logger.info("Starting Collector.")
    @top_dir_name = top_dir_name
    @organization = organization
    @api_key = api_key
    @host = host
    @saved_repos = read_bliss_file(top_dir_name) rescue {}
  end

  def git_init(git_dir)
    # cmd = get_cmd("cd #{git_dir};git init")
    cmd = "cd #{git_dir} && git init"
    `#{cmd}`
  end

  def git_log(dir_name)
    log_fmt = '"%H|%P|%ai|%aN|%aE|%s"'
    # command = "cd #{dir_name};git log --all --pretty=format:'#{log_fmt}' #{since_param}"
    # cmd = get_cmd(command)
    cmd = "cd #{dir_name} && git log --all --pretty=format:#{log_fmt}"
    `#{cmd}`
  end

  def prepare_log(organization, name, lines)
    puts "\tSaving repo data to AWS Bucket...".blue
    key = "#{organization}_#{name}_git.log"
    upload_to_aws('bliss-collector-files', key, lines)
    key
  end

  def execute
    agent = Mechanize.new
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    auth_headers = { 'X-User-Token' => @api_key }
    repos = {}

    dir_list = get_directory_list(@top_dir_name)
    puts "Found #{dir_list.count} repositories...".green
    dir_list.each do |dir_name|
      name = dir_name.split('/').last
      puts "Working on: #{name}...".blue
      # git_base_cmd = get_cmd("cd #{dir_name};git config --get remote.origin.url")
      git_base_cmd = "cd #{dir_name} && git config --get remote.origin.url"
      git_base = `#{git_base_cmd}`.gsub(/\n/, '')
      project_types = sense_project_type(dir_name)
      # Let this happen on the api for now
      # from_date = DateTime.parse(Time.new.to_s) - 6.months
      params = {
        name: name,
        full_name: "#{@organization}/#{name}",
        git_url: git_base,
        languages: project_types
      }
      checkout_commit(dir_name, 'master')

      puts "\tGetting list of commits for project #{name}...".blue
      @logger.info("Getting gitlog for #{name}")
      # lines = git_log(dir_name, get_since_param(name))
      lines = git_log(dir_name)
      commit_count = lines.split("\n").count
      puts "\tFound #{commit_count} commits in total.".green
      @logger.info("#{commit_count} commits found...")
      puts "\tSaving repository details to database...".blue
      repo_return = agent.post("#{@host}/api/repo.json", params, auth_headers)
      repo_details = JSON.parse(repo_return.body)
      puts "\tCreated repo ##{repo_details['id']} - #{repo_details['full_name']}".green
      json_return = JSON.parse(repo_return.body)
      repos[name] = json_return
      repos[name]["commit_count"] = commit_count
      repo_key = json_return['repo_key']
      if needs_running? @top_dir_name, name, commit_count
        puts "\tSaving Gitlog to AWS...".blue
        s3_object_key = prepare_log(@organization, name, lines)
        agent.post(
        "#{@host}/api/gitlog",
        { repo_key: repo_key, object_key: s3_object_key, bucket: 'bliss-collector-files' },
        auth_headers)
      else
        puts "\tNo new commits to process for repo #{name}...".green
        @logger.info("No new commits...")
      end
    end
    save_bliss_file(@top_dir_name, repos)
    @logger.success("Collector finished...")
    @logger.save_log
  end

  def needs_running? top_dir_name, repo_name, commit_count
    (new_repo? repo_name) || (@saved_repos[repo_name]["commit_count"] < commit_count)
  end

  def new_repo? repo_name
    !@saved_repos.has_key? repo_name
  end

  def get_since_param repo_name
    if (new_repo? repo_name) || (@saved_repos[repo_name]["start_from"].nil?)
      "--since=#{(DateTime.parse(Time.new.to_s) - 6.months).strftime("%Y-%m-%d")}"
      # "-100"
    else
      "--since=#{DateTime.parse(@saved_repos[repo_name]["start_from"]).strftime("%Y-%m-%d")}"
    end
  end
end
