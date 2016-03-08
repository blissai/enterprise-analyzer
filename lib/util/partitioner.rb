class Partitioner
  attr_accessor :partition_dirs
  BYTE_LIMIT = 26214400
  def initialize(src_dir, logger)
    @src_dir = src_dir
    @dir_analyzer = DirectoryAnalyzer.new(@src_dir)
    @logger = logger
  end

  def build_partition_lists
    exit_status = Open3.popen3("fpart -s #{BYTE_LIMIT} -x '.git' -o /tmp/partition #{@src_dir}") do |i, o, e, t|
      t.value
    end
    @partition_files = Dir.glob('/tmp/partition*')
  end

  def partition_files
    @logger.info("\tSplitting files into #{@partition_files.size} partitions...".blue)
    @partition_files.each_with_index do |pf, index|
      partition_dest = "/tmp/parts/#{SecureRandom.hex(3)}"
      files = File.read(pf).split("\n")
      files.each do |f|
        file_dest = File.dirname(File.join(partition_dest, f).sub(@src_dir, ''))
        `mkdir -p '#{file_dest}'`
        `cp '#{f}' '#{file_dest}'`
      end
    end
    Dir.glob('/tmp/parts/*')
  end

  def create_partitions
    if @dir_analyzer.too_big?
      @logger.info("\tRepository is too large. Creating partitions...")
      build_partition_lists
      @partition_dirs = partition_files
    else
      @partition_dirs = [@src_dir]
    end
    @partition_dirs
  end
end
