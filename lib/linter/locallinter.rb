class LocalLinter
  include Common
  include Gitbase
  include Linter

  def initialize(params)
    init_params(params)
    check_args
    @linter = YAML.load_file(@linter_config_path)
    @scrubber = SourceScrubber.new
    if @repo_key
      @status = Status.new(@repo_key, @commit, @linter['quality_tool'])
      @status.run
    end
  end

  def init_params(params)
    @logger = BlissLogger.new(nil, nil, params[:log_prefix])
    @git_dir = params[:git_dir]
    @linter_config_path = params[:linter_config_path]
    @commit = params[:commit]
    @name = params[:log_prefix]
    @excluded_dirs = params[:excluded_dirs]
    @remove_open_source = params[:remove_open_source]
    @repo_key = params[:repo_key]
    @output_file = '/result.txt'
    @api_key = nil
  end

  def execute
    checkout_commit(@git_dir, @commit)
    @logger.info('Removing open source and excluded files...')
    remove_excluded_directories(@excluded_dirs, @git_dir)
    remove_open_source_files(@git_dir) if @remove_open_source == true || @remove_open_source.nil?
    remove_symlinks(@git_dir)
    start = Time.now
    partition_and_lint(@linter)
    time = Time.now - start
    @status.finish if @status
    @logger.info("\tTook #{time} seconds to run #{@linter['quality_tool']}...")
  end

  def check_args
    valid = true
    if !File.exist? @git_dir
      @logger.error('Directory does not exist.')
      valid = false
    elsif @output_file.nil? || !File.exist?(@output_file)
      @logger.error('Please specify a writable file to output to.')
      valid = false
    elsif File.directory?(@output_file)
      @logger.error('Output file is a directory. Should be a file.')
      valid = false
    elsif @linter_config_path.nil? || !File.exist?(@linter_config_path)
      @logger.error('Linter config file does not exist.')
      valid = false
    elsif File.directory?(@linter_config_path)
      @logger.error('Linter config path is a directory. Should be a file.')
      valid = false
    elsif @commit.nil? || @commit.empty?
      @logger.error('Please specify a commit.')
      valid = false
    end
    exit 1 unless valid
  end
end
