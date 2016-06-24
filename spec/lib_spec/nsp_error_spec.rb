require_relative '../spec_helper.rb'
RSpec.describe NspError do

  before(:all) do
    @file_path = "#{Dir.pwd}/spec/fixtures/result.txt"
  end

  after(:all) do
    File.delete(@file_path) if File.exist?(@file_path)
  end

  let(:nsp_error) do
    s = NspError.new(File.expand_path(@file_path))
    s
  end

  context 'given an error json file' do
    it 'returns default error when file read failure' do
      File.delete(@file_path) if File.exist?(@file_path)
      nsp_error.handle_error
      expect(File.read(@file_path)).to eq('["Scan failed: Invalid package.json file."]')
    end

    it 'return default error when blank json' do
      file_content = File.read("#{Dir.pwd}/spec/fixtures/nsp_fail_blank.txt")
      File.write(@file_path, file_content)
      nsp_error.handle_error
      expect(File.read(@file_path)).to eq('["Scan failed: Invalid package.json file."]')
    end

    it 'returns extracted error' do
      file_content = File.read("#{Dir.pwd}/spec/fixtures/nsp_fail.txt")
      File.write(@file_path, file_content)
      nsp_error.handle_error
      expected = ['Scan failed: Error: child "package" fails because' \
      ' [child "version" fails because ["version" with value "0.4" fails to match the' \
      ' required pattern: /\\d+\\.\\d+\\.\\d+(-*)?/]]'].to_json
      expect(JSON.parse(File.read(@file_path))).to eq(JSON.parse(expected))
    end
  end
end
