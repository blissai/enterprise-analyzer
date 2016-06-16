module Http
  # function to retry http GET requests
  def http_get(url)
    exponential_backoff do
      @mutex.synchronize do
        begin
          response = @agent.get(url, @auth_headers)
          return JSON.parse(response.body)
        rescue Net::HTTP::Persistent::Error
          reset_http_agent
          response = @agent.get(url, @auth_headers)
          return JSON.parse(response.body)
        end
      end
    end
  end

  # function to retry http POST requests
  def http_post(url, params, json = false)
    content_type = {}
    if json && params
      params = params.to_json
      content_type['Content-Type'] = 'application/json'
    end
    headers = @auth_headers.merge(content_type)
    exponential_backoff do
      @mutex.synchronize do
        begin
          response = @agent.post(url, params, headers)
          return JSON.parse(response.body)
        rescue Net::HTTP::Persistent::Error
          reset_http_agent
          response = @agent.post(url, params, headers)
          return JSON.parse(response.body)
        end
      end
    end
  end

  def http_multipart_put(url, file_content)
    content_type = { 'Content-Type' => 'multipart/form-data' }
    headers = @auth_headers.merge(content_type)
    exponential_backoff do
      @mutex.synchronize do
        begin
          @agent.put(url, file_content, headers)
        rescue Net::HTTP::Persistent::Error
          reset_http_agent
          @agent.put(url, file_content, headers)
        end
      end
    end
  end

  def exponential_backoff(&code)
    ExponentialBackoff.new(5, http_errors).run(&code)
  end

  def configure_http
    @agent = Mechanize.new { |m| m.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE }
    @auth_headers = { 'X-User-Token' => @api_key }
    @mutex = Mutex.new
  end

  def reset_http_agent
    @agent.shutdown
    configure_http
  end

  def http_errors
    {
      Mechanize::ResponseCodeError => {
        rescuable: true,
        action: proc do
          puts 'Warning: Server in maintenance mode.'.yellow
        end
      },
      Mechanize::UnauthorizedError => {
        rescuable: false,
        action: proc do
          abort 'Your API key is not valid.'.red
        end
      },
      JSON::ParserError => {
        rescuable: true,
        action: proc do
          puts 'Warning: Server in maintenance mode.'.yellow
        end
      },
      SocketError => {
        rescuable: false,
        action: proc do
          abort 'Docker seems to have lost connectivity. Please restart Docker and try again.'.red
        end
      }
    }
  end
end
