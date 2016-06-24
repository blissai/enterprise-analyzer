class LocalStats
  include Gitbase
  include Stats

  def initialize(params)
    @logger = BlissLogger.new
    init_params(params)
    if @repo_key
      @status = Status.new(@repo_key, @commit, nil, nil)
      @status.run
    end
    check_args
  end

  def execute
    File.write(@output_file, execute_stats_cmd(@commit).to_json)
  end

  private

  def init_params(params)
    @commit = params[:commit]
    @git_dir = params[:git_dir]
    @name = params[:log_prefix]
    @excluded_dirs = params[:excluded_dirs]
    @repo_test_files = params[:repo_test_files]
    @repo_test_dirs = params[:repo_test_dirs]
    @repo_excluded_exts = params[:excluded_exts]
    @repo = { 'detect_open_source' => params[:remove_open_source] }
    @repo_key = params[:repo_key]
    @output_file = params[:output_file] || '/result.txt'
    @api_key = nil
  end

  def check_args
    valid = true
    if !File.exist? @git_dir
      @logger.error("#{@name} - Directory does not exist.")
      valid = false
    elsif @output_file.nil? || !File.exist?(@output_file)
      @logger.error("#{@name} - Please specify a writable file to output to.")
      valid = false
    elsif File.directory?(@output_file)
      @logger.error("#{@name} - Output file is a directory. Should be a file.")
      valid = false
    elsif @commit.nil? || @commit.empty?
      @logger.error("#{@name} - Please specify a commit.")
      valid = false
    end
    exit 1 unless valid
  end
end
