# Read state from daemon file
module Daemon
  STATUSFILE = File.expand_path('/pstatus').freeze
  RUNNING = 'Running...'.freeze

  def status
    status = nil
    File.open(STATUSFILE, 'r') do |f|
      f.flock(File::LOCK_SH)
      status = f.read
    end
    status
  end

  def stop_daemon?
    ENV['daemonized'] && File.exist?(STATUSFILE) && status != RUNNING
  end
end
