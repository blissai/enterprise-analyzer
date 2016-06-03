class Status
  attr_accessor :finished
  include Common
  def initialize(repo_key, commit, quality_tool = nil, api_key = nil)
    @repo_key = repo_key
    @commit = commit
    @quality_tool = quality_tool
    @api_key = api_key
    @finished = false
    @host = ENV['BLISS_HOST']
    configure_http
  end

  def run
    ping
    @background_thread = Thread.new do
      loop do
        wait
        ping
      end
    end
  end

  def finish
    Thread.kill(@background_thread)
  end

  def ping
    url = "#{@host}/api/status/ping"
    http_post(url, commit: @commit, repo_key: @repo_key,
                                                              quality_tool: @quality_tool)
  end

  private

  def wait
    sleep 30
  end
end
