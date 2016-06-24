require_relative '../spec_helper.rb'
RSpec.describe LocalLinter do
  context 'local linter' do
    it 'should abort with bad git_dir' do
      expect do
        LocalLinter.new(log_prefix: 'test', git_dir: '/blah/some_non_existent_dir')
      end.to raise_error SystemExit
    end

    it 'should abort with bad output file' do
      expect do
        LocalLinter.new(log_prefix: 'test', git_dir: Dir.pwd)
      end.to raise_error SystemExit
    end

    it 'should abort with bad output file' do
      expect do
        LocalLinter.new(log_prefix: 'test', git_dir: Dir.pwd)
      end.to raise_error SystemExit
    end
  end
end
