require 'nokogiri'
class SourceScrubber
  def scrub(report)
    text = report
    # CPD
    if report.include? "<?xml"
      text = Nokogiri::XML(report)
      codefrags = text.search('codefragment')
      codefrags.remove
    end
    text.to_s
    # report.gsub(/<codefragment>.*<\/codefragment>/, "")
  end
end
