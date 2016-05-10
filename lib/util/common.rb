# Set of common functions used by all commands
module Common
  def configure_http
    @agent = Mechanize.new { |m| m.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE }
    @auth_headers = { 'X-User-Token' => @api_key }
  end

  def reset_http_agent
    $HTTP_MUTEX.synchronize do
      @agent.shutdown
      configure_http
    end
  end

  def init_configuration(git_dir, api_key, host, repo)
    @git_dir = git_dir
    @name = repo['full_name'].split('/').last
    @organization = repo['full_name'].split('/').first
    @api_key = api_key
    @host = host
    @repo = repo
    @repo_key = @repo['repo_key']
  end

  def get_cmd(cmd)
    "(#{cmd})"
  end

  def get_directory_list(top_dir_name)
    top_dir_with_star = File.join(top_dir_name.to_s, '*')
    Dir.glob(top_dir_with_star).select { |f| File.directory?(f) && git_dir?(f) }
  end

  def save_bliss_file(top_dir_name, data)
    File.open("#{top_dir_name}/.bliss.json", 'w') do |f|
      f.write(data.to_json)
    end
  end

  def read_bliss_file(top_dir_name)
    JSON.parse(File.open("#{top_dir_name}/.bliss.json", 'r').read)
  end

  # Recursive function to retry http GET requests
  def http_get(url)
    json_return = exponential_backoff do
      response = @agent.get(url, @auth_headers)
      json_return = JSON.parse(response.body)
    end
    json_return
  end

  # Recursive function to retry http POST requests
  def http_post(url, params = nil, json = false)
    exponential_backoff = ExponentialBackoff.new(5, )
    json_return = nil
    if json && params
      params = params.to_json
      @auth_headers['Content-Type'] = 'application/json'
    end
    json_return = exponential_backoff do
      response = @agent.post(url, params, @auth_headers)
      json_return = JSON.parse(response.body)
    end
    json_return
  end

  def exponential_backoff(&code)
    eb = ExponentialBackoff.new(5,
      Mechanize::ResponseCodeError => 'Warning: Server in maintenance mode, trying again.',
      Net::HTTP::Persistent::Error => 'Net::ReadTimeout error occurred.'.red
    )
    eb.run do
      yield
    end
  end

  def http_errors
    {
      Mechanize::ResponseCodeError => {
        msg: 'Warning: Server in maintenance mode, trying again.',
        rescuable: true
      },
      Net::HTTP::Persistent::Error => {
        msg: 'Net::ReadTimeout error occurred.',
        rescuable: true
      },
      Mechanize::UnauthorizedError => {
        msg: 'Your API key is not valid.',
        rescuable: false
      }
    }
  end

  def exponential_backoff
    json_return = nil
    begin
      $HTTP_MUTEX.synchronize do
        yield(url, params, json)
      end
    rescue Mechanize::UnauthorizedError
      @logger.error('Your API key is not valid.') if @logger
    rescue Mechanize::ResponseCodeError
      if tried < 5
        puts "Warning: Server in maintenance mode, waiting for #{2**tried} seconds and trying again".yellow
        sleep(2**tried)
        $HTTP_MUTEX.synchronize do
          yield(url, params, json)
        end
      else
        @logger.error("Warning: Can't connect to Bliss server... Tried max times.") if @logger
      end
    rescue Net::HTTP::Persistent::Error
      if tried < 5
        reset_http_agent
        $HTTP_MUTEX.synchronize do
          yield(url, params, json)
        end
      else
        @logger.error('Net::ReadTimeout error occurred. Tried too many times') if @logger
      end
    end
    json_return
  end

  def http_get(url)
    eb = ExponentialBackoff.new
  end

  def todo_count(repo_key, type, tried = 0)
    count_json = http_get("#{@host}/api/gitlog/#{type}_todo_count?repo_key=#{repo_key}")
    count = count_json["#{type}_todo"].to_i
    max = 5
    if count > 0
      return count
    elsif tried < 5
      show_wait_cursor(2**tried, tried + 1, max)
      return todo_count(repo_key, type, tried + 1)
    else
      print "\n"
      return 0
    end
  end

  def show_wait_cursor(seconds, tried, max, fps = 10)
    chars = %w(| / - \\)
    delay = 1.0 / fps
    (seconds * fps).round.times do |i|
      seconds_left = seconds - (i / fps)
      print "\t(#{tried}/#{max}) No jobs found... Trying again in #{seconds_left} seconds #{chars[i % chars.length]}     \r".yellow
      sleep delay
    end
  end
end
