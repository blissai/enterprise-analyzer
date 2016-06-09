class Partitioner
  attr_accessor :partition_dirs
  def initialize(src_dir, logger, linter, byte_limit = 26_214_400)
    @src_dir = src_dir
    @linter = linter
    @dir_analyzer = DirectoryAnalyzer.new(@src_dir, @linter['max_lines'])
    @logger = logger
    @byte_limit = byte_limit
  end

  def build_partition_lists
    cmd = "fpart -s #{@byte_limit} -x '.git' -o /tmp/partition #{@src_dir}"
    _exit_status = Open3.popen3(cmd) do |_i, _o, _e, t|
      t.value
    end
    @partition_files = Dir.glob('/tmp/partition*')
  end

  def partition_files
    @logger.info("\tSplitting files into #{@partition_files.size} partitions...".blue)
    @partition_files.each_with_index do |pf, _index|
      partition_destination = "/tmp/parts/#{SecureRandom.hex(3)}"
      files = File.read(pf).split("\n")
      files.each do |file|
        copy_file_to_partition(file, partition_destination)
      end
    end
    Dir.glob('/tmp/parts/*')
  end

  def copy_file_to_partition(file, partition_destination)
    file_destination = File.dirname(File.join(partition_destination, file).sub(@src_dir, ''))
    FileUtils.mkdir_p(file_destination)
    FileUtils.cp(file, file_destination)
  rescue
    @logger.warn("Could not copy. Skipping #{file}...")
  end

  def create_partitions
    if @dir_analyzer.too_big? && @linter['partitionable']
      @logger.info("\tRepository is too large. Creating partitions...")
      build_partition_lists
      @partition_dirs = partition_files
    else
      @partition_dirs = [@src_dir]
    end
    @partition_dirs
  end
end
