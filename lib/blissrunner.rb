# A class to handle config and instantiation of tasks
class BlissRunner
  def initialize(auto = false, beta = false)
    # Load configuration File if it exists
    if File.exist? "#{File.expand_path('~/bliss-config.yml')}"
      @config = YAML.load_file("#{File.expand_path('~/bliss-config.yml')}")
    else
      @config = {}
    end
    @beta = beta
    FileUtils.mkdir_p "#{File.expand_path('~/collector/logs')}"
    if auto
      configure_aws(@config['AWS_ACCESS_KEY_ID'], @config['AWS_SECRET_ACCESS_KEY'])
    else
      get_config
    end
    DependencyInstaller.new(@config['TOP_LVL_DIR']).run
  end

  # Global AWS Configuration
  def configure_aws(key, secret)
    puts 'Configuring AWS...'.blue
    # If Windows, use AWS's bundled ssl cert
    Aws.use_bundled_cert! if Gem.win_platform?
    # do this once, and all s3 clients will now accept `:requester_pays` to all operations
    Aws::S3::Client.add_plugin(RequesterPays)
    aws_credentials = Aws::Credentials.new(key, secret)
    # Aws.config.update(region: 'us-east-1', credentials: aws_credentials)
    $aws_client = Aws::S3::Client.new(region: 'us-east-1', credentials: aws_credentials)
    puts 'AWS configured.'.green
  end

  # Initialize state from config file or user input
  def get_config
    puts 'Configuring collector...'
    get_or_save_arg('What\'s your Bliss API Key?', 'API_KEY')
    get_or_save_arg('Which directory are your repositories located in?', 'TOP_LVL_DIR')
    get_or_save_arg('What\'s your AWS Access Key?', 'AWS_ACCESS_KEY_ID')
    get_or_save_arg('What\'s your AWS Access Secret?', 'AWS_SECRET_ACCESS_KEY')
    # get_or_save_arg('What is the hostname of your Bliss instance?', 'BLISS_HOST')
    get_or_save_arg('What is the name of your organization in git?', 'ORG_NAME')
    set_host
    File.open("#{File.expand_path('~')}/bliss-config.yml", 'w') { |f| f.write @config.to_yaml } # Store
    puts 'Collector configured.'.green
    configure_aws(@config['AWS_ACCESS_KEY_ID'], @config['AWS_SECRET_ACCESS_KEY'])
  end

  def choose_command
    # binding.pry
    ctasks = ConcurrentTasks.new(@config)
    puts 'Which command would you like to run? ((C)ollector, (S)tats, (L)inter or (Q)uit).'
    command = gets.chomp.upcase
    if command == 'C'
      puts 'Running Collector'
      CollectorTask.new(@config['TOP_LVL_DIR'], @config['ORG_NAME'], @config['API_KEY'], @config['BLISS_HOST']).execute
    elsif command == 'L'
      puts 'Running Linter'
      ctasks.linter
    elsif command == 'S'
      puts 'Running Stats'
      ctasks.stats
    # elsif command == 'T'
    #   schedule_job
    else
      puts 'Not a valid option. Please choose Collector, Lint, Stats or Quit.' unless command == 'Q'
    end
    choose_command unless command.eql? 'Q'
  end

  # A function that automates the above three functions for a scheduled job
  def automate
    if configured?
      CollectorTask.new(@config['TOP_LVL_DIR'], @config['ORG_NAME'], @config['API_KEY'], @config['BLISS_HOST']).execute
      # Sleep to wait for workers to finish
      sleep(60)
      ctasks = ConcurrentTasks.new(@config)
      ctasks.stats
      # Sleep to wait for workers to finish
      sleep(60)
      ctasks.linter
    else
      puts 'Collector has not been configured. Cannot run auto-task.'.red
    end
  end

  def configured?
    !@config['TOP_LVL_DIR'].empty? && !@config['ORG_NAME'].empty? && !@config['API_KEY'].empty? && !@config['BLISS_HOST'].empty?
  end

  # A function to set up a scheduled job to run 'automate' every x number of minutes
  def schedule_job
    puts 'How often would you like to automatically run Bliss Collector?'.blue
    puts " (1) Every Day\n (2) Every Hour\n (3) Every 10 Minutes"
    option = gets.chomp
    if ![1, 2, 3].include? option.to_i
      puts 'This is not a valid option. Please choose 1, 2, or 3.'
    else
      if Gem.win_platform?
        task_sched(option)
      else
        cron_job(option)
      end
    end
  end

  def task_sched(option)
    # Choose frequency
    if option == 1
      freq = '/SC DAILY'
    elsif option == 2
      freq = '/SC HOURLY'
    else
      freq = '/SC MINUTE /MO 10'
    end

    # Get current path
    cwd = `@powershell $pwd.path`.gsub(/\n/, '')
    task_cmd = "cd  #{cwd}\nruby blissauto.rb"

    # create batch file
    file_name = "#{cwd}\\blisstask.bat"
    File.open(file_name, 'w') { |file| file.write(task_cmd) }

    # schedule task with schtasks
    cmd = "schtasks /Create #{freq} /TN BlissCollector /TR #{file_name}"
    `#{cmd}`
  end

  def cron_job(option)
    # Create a shell script that runs blissauto
    cwd = `pwd`.gsub(/\n/, '')
    cron_command = "cd  #{cwd}; ruby blisscollector.rb --auto"
    file_name = "#{cwd}/blisstask.sh"
    File.open(file_name, 'w') { |file| file.write(cron_command) }
    # Format cron entry
    if option == 1
      cron_entry = "@daily #{file_name}"
    elsif option == 2
      cron_entry = "@hourly #{file_name}"
    else
      cron_entry = "*/10 * * * * #{file_name}"
    end

    # Create a file for Cron
    File.open('/etc/cron.d/bliss', 'w') { |file| file.write(cron_entry) }
    puts 'Job scheduled successfully.'.green
  end

  def set_host
    if @beta
      @config['BLISS_HOST'] = 'https://beta.founderbliss.com'
    else
      @config['BLISS_HOST'] ||= 'https://app.founderbliss.com'
    end
  end

  def is_git_dir(dir)
    system("cd #{dir} && git rev-parse")
  end

  def is_valid_arg(env, arg)
    if env.eql? 'TOP_LVL_DIR'
      if !File.directory?(arg)
        m = 'That is not a valid directory. Please enter a directory that contains your git repository folders.'
      elsif is_git_dir(arg)
        m = 'That is a git directory. Please enter a directory that contains your git repository folders, not the repository folders themselves.'
      end
      return { valid: m.nil?, msg: m }
    else
      return { valid: true, msg: nil }
    end
  end

  private

  # Checks for saved argument in config file, otherwise prompts user
  def get_or_save_arg(message, env_name)
    if @config && @config[env_name]
      puts "Loading #{env_name} from bliss-config.yml...".blue
    else
      puts message.blue
      arg = gets.chomp
      valid = is_valid_arg(env_name, arg)
      if !valid[:valid]
        get_or_save_arg(valid[:msg], env_name)
      else
        @config[env_name] = arg
      end
    end
  end
end
