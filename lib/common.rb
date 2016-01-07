# Set of common functions used by all commands
module Common
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
  def http_get(agent, url, auth, tried = 0)
    json_return = nil
    begin
      response = agent.get(url, auth)
      json_return = JSON.parse(response.body)
    rescue Mechanize::UnauthorizedError => ue
      puts "Error: Your API key is not valid.".red
      @logger.error("Invalid API Key.")
    rescue Mechanize::ResponseCodeError => re
      if tried < 3
        puts "Warning: Server in maintenance mode, waiting for 20 seconds and trying again".yellow
        sleep(20)
        http_get(agent, url, auth, tried + 1)
      else
        puts "Warning: Can't connect to Bliss server... Tried max times.".yellow
        @logger.error("Warning: Can't connect to Bliss server... Tried max times.")
      end
    end
    json_return
  end


  # Recursive function to retry http POST requests
  def http_post(agent, url, params, auth, tried = 0)
    json_return = nil
    begin
      response = agent.post(url, params, auth)
      json_return = JSON.parse(response.body)
    rescue Mechanize::UnauthorizedError => ue
      puts "Error: Your API key is not valid.".red
      @logger.error("Invalid API Key.")
    rescue Mechanize::ResponseCodeError => re
      if tried < 3
        puts "Warning: Server in maintenance mode, waiting for 20 seconds and trying again".yellow
        sleep(20)
        http_post(agent, url, params, auth, tried + 1)
      else
        puts "Warning: Can't connect to Bliss server... Tried max times.".yellow
        @logger.error("Warning: Can't connect to Bliss server... Tried max times.")
      end
    end
    json_return
  end
end
