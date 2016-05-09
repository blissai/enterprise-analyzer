class Status
  attr_accessor :finished
  include Common
  def initialize(repo_key, commit, api_key = nil)
    @repo_key = repo_key
    @commit = commit
    @api_key = api_key
    @finished = false
    @mutex = Mutex.new
    configure_http
  end

  def run
    start
    @bt = Thread.new do
      loop do
        ping
        sleep 30
        break if @finished
      end
    end
    @bt.join
  end

  def finish
    @mutex.synchronize { @finished = true }
  end

  def ping
    update(false)
  end

  def start
    update(true)
  end

  def update(started)
    http_post('https://app.founderbliss.com/api/status/ping', commit: @commit, start: started)
  end
end
