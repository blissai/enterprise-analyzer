# NSP error handling
class NspError
  def initialize(result_path)
    @result_path = result_path
    @result = begin
      File.read(@result_path)
    rescue
      ''
    end
  end

  def handle_error
    File.write(@result_path, [extract_error].to_json)
  end

  private

  def extract_error
    e = JSON.parse(@result.split("\n").first.gsub('Debug output: ', ''))
    return "Scan failed: #{e['message']}" if e['message']
    return 'Scan failed: Invalid package.json file.'
  rescue
    'Scan failed: Invalid package.json file.'
  end
end
