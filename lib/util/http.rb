module Http
  # function to retry http GET requests
  def http_get(url)
    json_return = exponential_backoff do
      begin
        response = @agent.get(url, @auth_headers)
      rescue Net::HTTP::Persistent::Error
        response = @agent.get(url, @auth_headers)
        reset_http_agent
      end
      json_return = JSON.parse(response.body)
    end
    json_return
  end

  # function to retry http POST requests
  def http_post(url, params, json = false)
    json_return = nil
    if json && params
      params = params.to_json
      @auth_headers['Content-Type'] = 'application/json'
    end
    json_return = exponential_backoff do
      begin
        response = @agent.post(url, params, @auth_headers)
      rescue Net::HTTP::Persistent::Error
        reset_http_agent
        response = @agent.post(url, params, @auth_headers)
      end
      json_return = JSON.parse(response.body)
    end
    json_return
  end

  def http_mutipart_put(url, file_content)
    @auth_headers['Content-Type'] = 'multipart/form-data'
    exponential_backoff do
      begin
        @agent.put(url, file_content, @auth_headers)
      rescue Net::HTTP::Persistent::Error
        reset_http_agent
        @agent.put(url, file_content, @auth_headers)
      end
    end
  end

  def exponential_backoff(&code)
    ExponentialBackoff.new(5, http_errors).run(&code)
  end

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

  def http_errors
    {
      Mechanize::ResponseCodeError => {
        rescuable: true,
        action: Proc.new do
          puts 'Warning: Server in maintenance mode.'.yellow
        end
      },
      Mechanize::UnauthorizedError => {
        rescuable: false,
        action: Proc.new do
          puts 'Your API key is not valid.'.red
        end
      }
    }
  end
end
