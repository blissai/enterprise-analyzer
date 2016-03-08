class BlissLogger
  include Common
  def initialize(api_key = nil, repo_key = nil, log_prefix = '')
    @api_key = api_key
    configure_http
    @auth_headers = {}
    repo_key(repo_key)
    @mutex = Mutex.new
    @log_prefix = log_prefix.empty? ? '' : "#{log_prefix} - "
  end

  def repo_key(repo_key = nil)
    if repo_key
      @repo_key = repo_key
    else
      @repo_key
    end
  end

  def error(line)
    @mutex.synchronize do
      print "#{@log_prefix}#{line}\n".red
      log_to_papertrail("Error: #{line}")
    end
  end

  def info(line)
    @mutex.synchronize do
      print "#{@log_prefix}#{line}\n".blue
      log_to_papertrail("Info: #{line}")
    end
  end

  def warn(line)
    @mutex.synchronize do
      print "#{@log_prefix}#{line}\n".yellow
      log_to_papertrail("Warn: #{line}")
    end
  end

  def success(line)
    @mutex.synchronize do
      print "#{@log_prefix}#{line}\n".green
      log_to_papertrail("Success: #{line}")
    end
  end

  def log_to_papertrail(line)
    http_post('https://app.founderbliss.com/api/gitlog/enterprise_log',
              api_key: @api_key, repo_key: @repo_key, message: "#{@log_prefix}#{line.gsub!(/\t/, '')}")
  end
end
