at_exit do
  unless $!.nil? || $!.is_a?(SystemExit) && $!.success?
    logger = BlissLogger.new(nil, nil, 'DockerError')
    logger.error("#{$!.backtrace}\n#{$!.message}", $!.class)
  end
end
