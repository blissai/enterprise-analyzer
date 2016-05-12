class BlissLogger
  include Common
  API_ENDPOINT = 'https://app.founderbliss.com/api/gitlog/enterprise_log'.freeze
  def initialize(api_key = nil, repo_key = nil, log_prefix = '')
    @api_key = api_key
    configure_http
    @auth_headers = {}
    repo_key(repo_key)
    @log_prefix = log_prefix.empty? ? '' : "#{log_prefix} - "
  end

  def repo_key(repo_key = nil)
    if repo_key
      @repo_key = repo_key
    else
      @repo_key
    end
  end

  def error(line, error = nil)
    print "#{@log_prefix}#{line}\n".red
    if error
      log_to_bugsnag(line, error)
    else
      log_to_papertrail("Error: #{line}")
    end
  end

  def info(line)
    print "#{@log_prefix}#{line}\n".blue
    log_to_papertrail("Info: #{line}")
  end

  def warn(line)
    print "#{@log_prefix}#{line}\n".yellow
    log_to_papertrail("Warn: #{line}")
  end

  def success(line)
    print "#{@log_prefix}#{line}\n".green
    log_to_papertrail("Success: #{line}")
  end

  private

  def log_to_papertrail(line)
    http_post(API_ENDPOINT, log_params(line))
  end

  def log_to_bugsnag(line, error)
    http_post(API_ENDPOINT, log_params(line).merge(error: error))
  end

  def log_params(line)
    { api_key: @api_key, repo_key: @repo_key, message: "#{@log_prefix}#{line.gsub!(/\t/, '')}" }
  end
end
