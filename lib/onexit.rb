at_exit do
  err = $!
  unless err.nil? || err.is_a?(SystemExit) && err.success?
    logger = BlissLogger.new(nil, nil, 'DockerError')
    logger.error("#{err.backtrace}\n#{err.message}", err.class)
  end
end
