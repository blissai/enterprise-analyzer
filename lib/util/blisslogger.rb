class BlissLogger
  include Common
  def initialize(api_key = nil, repo_key = nil)
    @api_key = api_key
    configure_http
    @auth_headers = {}
    repo_key(repo_key)
  end

  def repo_key(repo_key = nil)
    if repo_key
      @repo_key = repo_key
    else
      @repo_key
    end
  end

  def error(line)
    print "#{line}\n".red
    log_to_papertrail("Error: #{line}")
  end

  def info(line)
    print "#{line}\n".blue
    log_to_papertrail("Info: #{line}")
  end

  def warn(line)
    print "#{line}\n".yellow
    log_to_papertrail("Warn: #{line}")
  end

  def success(line)
    print "#{line}\n".green
    log_to_papertrail("Success: #{line}")
  end

  def log_to_papertrail(line)
    http_post('https://app.founderbliss.com/api/gitlog/enterprise_log',
              api_key: @api_key, repo_key: @repo_key, message: line.gsub!(/\t/, ''))
  end
end
