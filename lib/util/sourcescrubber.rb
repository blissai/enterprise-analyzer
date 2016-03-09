require 'nokogiri'
class SourceScrubber
  def scrub(report)
    partitions = report.split("<--LintFilePartition-->\n").select { |lfs| !lfs.empty? }
    # CPD
    result = ''
    partitions.each do |part|
      next unless part.include? '<?xml'
      text = Nokogiri::XML(part)
      codefrags = text.search('codefragment')
      codefrags.remove
      result += "<--LintFilePartition-->\n#{text}"
    end
    result
  end
end
