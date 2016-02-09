# Set of common functions used by all commands
module Common
  def configure_http
    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @auth_headers = { 'X-User-Token' => @api_key }
  end

  def init_configuration(git_dir, api_key, host, repo, quick = false)
    @git_dir = git_dir
    @name = @git_dir.split('/').last
    @organization = repo['full_name'].split('/').first
    @api_key = api_key
    @host = host
    @repo = repo
    @repo_key = @repo['repo_key']
    @quick = quick
  end

  def get_cmd(cmd)
    if Gem.win_platform?
      @tmpbatchfile = Tempfile.new(['batch', '.ps1'])
      @tmpbatchfile.write(cmd.gsub(';', "\r\n"))
      @tmpbatchfile.close
      "powershell #{@tmpbatchfile.path}"
    else
      "(#{cmd})"
    end
  end

  def get_directory_list(top_dir_name)
    top_dir_with_star = File.join(top_dir_name.to_s, '*')
    Dir.glob(top_dir_with_star).select { |f| File.directory? f }
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
      response = @agent.get(url, @auth_headers)
      json_return = JSON.parse(response.body)
    rescue Mechanize::UnauthorizedError => ue
      puts "Error: Your API key is not valid.".red
      @logger.error("Invalid API Key.")
    rescue Mechanize::ResponseCodeError => re
      if tried < 3
        puts "Warning: Server in maintenance mode, waiting for 20 seconds and trying again".yellow
        sleep(20)
        http_get(url, tried + 1)
      else
        puts "Warning: Can't connect to Bliss server... Tried max times.".yellow
        @logger.error("Warning: Can't connect to Bliss server... Tried max times.")
      end
    end
    json_return
  end


  # Recursive function to retry http POST requests
  def http_post(url, params, tried = 0)
    json_return = nil
    begin
      response = @agent.post(url, params, @auth_headers)
      json_return = JSON.parse(response.body)
    rescue Mechanize::UnauthorizedError => ue
      puts "Error: Your API key is not valid.".red
      @logger.error("Invalid API Key.")
    rescue Mechanize::ResponseCodeError => re
      if tried < 5
        puts "Warning: Server in maintenance mode, waiting for 20 seconds and trying again".yellow
        sleep(2**tried)
        http_post(url, params, tried + 1)
      else
        puts "Warning: Can't connect to Bliss server... Tried max times.".yellow
        @logger.error("Warning: Can't connect to Bliss server... Tried max times.")
      end
    end
    json_return
  end

  def stats_todo_count(repo_key, tried = 0)
    count_json = http_get("#{@host}/api/gitlog/stats_todo_count?repo_key=#{repo_key}")
    count = count_json["stats_todo"].to_i
    if count > 0
      return count
    elsif tried < 7
      sleep(2**tried)
      return stats_todo_count(repo_key, tried + 1)
    else
      return 0
    end
  end

  def linters_todo_count(repo_key, tried = 0)
    count_json = http_get("#{@host}/api/gitlog/linters_todo_count?repo_key=#{repo_key}")
    count = count_json["linters_todo"].to_i
    if count > 0
      return count
    elsif tried < 7
      sleep(2**tried)
      return linters_todo_count(repo_key, tried + 1)
    else
      return 0
    end
  end
end
