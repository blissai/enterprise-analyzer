class DirectoryAnalyzer
  MAX_LINES = 750000
  attr_reader :directory
  attr_reader :total_lines

  def initialize(dir)
    @directory = File.expand_path(dir)
    calculate_total_lines
  end

  def too_big?
    @total_lines > MAX_LINES
  end

  private

  def calculate_total_lines
    cmd = "find #{@directory} -type f \\( #{supported_files} \\) -exec cat -- {} + | wc -l"
    @total_lines = `#{cmd}`.strip.to_i
  end

  # Supported extensions to search for
  def supported_files
    langs = %w(sh rb py go m mm h cpp css js class java php bat ps1 swift f pm pl)
    '-name "' + langs.join('" -o -name "*.') + '"'
  end
end
