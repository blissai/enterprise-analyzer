# Set of common functions used by all commands
module Common
  def configure_http
    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @auth_headers = { 'X-User-Token' => @api_key }
  end

  def init_configuration(git_dir, api_key, host, repo)
    @git_dir = git_dir
    @name = @git_dir.split('/').last
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
  def http_get(url, tried = 0)
    json_return = nil
    begin
      $HTTP_MUTEX.synchronize do
        response = @agent.get(url, @auth_headers)
        json_return = JSON.parse(response.body)
      end
    rescue Mechanize::UnauthorizedError => ue
      @logger.error('Your API key is not valid.')
    rescue Mechanize::ResponseCodeError => re
      if tried < 3
        puts "Warning: Server in maintenance mode, waiting for 20 seconds and trying again".yellow
        sleep(20)
        http_get(url, tried + 1)
      else
        @logger.error("Warning: Can't connect to Bliss server... Tried max times.")
      end
    end
    json_return
  end

  # Recursive function to retry http POST requests
  def http_post(url, params, tried = 0)
    json_return = nil
    begin
      $HTTP_MUTEX.synchronize do
        response = @agent.post(url, params, @auth_headers)
        json_return = JSON.parse(response.body)
      end
    rescue Mechanize::UnauthorizedError => ue
      @logger.error('Your API key is not valid.') if @logger
    rescue Mechanize::ResponseCodeError => re
      if tried < 5
        puts "Warning: Server in maintenance mode, waiting for #{2**tried} seconds and trying again".yellow
        sleep(2**tried)
        http_post(url, params, tried + 1)
      else
        puts "Error: Can't connect to Bliss server... Tried max times.".red
      end
    end
    json_return
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
      seconds_left = seconds - (i/fps)
      print "\t(#{tried}/#{max}) No jobs found... Trying again in #{seconds_left} seconds #{chars[i % chars.length]}     \r".yellow
      sleep delay
    end
  end
end
