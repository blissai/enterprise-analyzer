# NSP error handling
class RubocopError
  def initialize(error, result_path)
    @result_path = result_path
    @result = error || 'Invalid configuration file.'
  end

  def handle_error
    File.write(@result_path, { bliss_linter_config_error: @result }.to_json)
  end
end
