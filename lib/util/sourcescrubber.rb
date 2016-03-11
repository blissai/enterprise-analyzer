require 'nokogiri'
class SourceScrubber
  def scrub(report)
    partitions = report.split("<--LintFilePartition-->\n").select { |lfs| !lfs.empty? }
    # CPD
    result = ''
    partitions.each do |part|
      if part.include? '<?xml'
        text = Nokogiri::XML(part)
        codefrags = text.search('codefragment')
        codefrags.remove
      else
        text = part
      end
      result += "<--LintFilePartition-->\n#{text}"
    end
    result
  end
end
