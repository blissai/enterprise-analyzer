class BlissLogger
  include AwsUploader

  def initialize(log_name)
    FileUtils.mkdir_p(File.expand_path('~/collector/logs'))
    logger_path = File.expand_path("~/collector/logs/#{log_name}.txt")
    @logger = Logger.new(logger_path, 'daily')
    @aws_log = ''
    @log_name = log_name
  end

  def log_to_aws(line)
    log_line = "#{Time.now.strftime('%d-%m-%y-T%H-%M')} - #{line}"
    @aws_log += log_line + "\n"
  end

  def error(line)
    print "#{line}\n".red
    @logger.error(line)
    log_to_aws("Error: #{line}")
  end

  def info(line)
    print "#{line}\n".blue
    @logger.info(line)
    log_to_aws("Info: #{line}")
  end

  def warn(line)
    print "#{line}\n".yellow
    @logger.warn(line)
    log_to_aws("Warn: #{line}")
  end

  def success(line)
    print "#{line}\n".green
    @logger.warn(line)
    log_to_aws("Success: #{line}")
  end

  def save_log
    unless @aws_log.empty?
      key = "#{@log_name}-#{Time.now.strftime('%d-%m-%y-T%H-%M')}"
      upload_to_aws('bliss-collector-logs-docker', key, @aws_log)
    end
  end
end
