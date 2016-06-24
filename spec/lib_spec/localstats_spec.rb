require_relative '../spec_helper.rb'
RSpec.describe LocalStats do
  before do
    allow_any_instance_of(BlissLogger).to receive(:log_to_papertrail).and_return(true)
    allow_any_instance_of(LocalStats).to receive(:execute_stats_cmd).and_return(cloc: 'some stats')
  end

  before(:all) do
    @output_file = "#{Dir.pwd}/spec/fixtures/result.txt"
    FileUtils.touch(@output_file)
    @params = {
      log_prefix: 'test',
      git_dir: "#{Dir.pwd}/spec/fixtures/projs/php",
      output_file: @output_file,
      commit: 'master',
      remove_open_source: false,
      excluded_dirs: []
    }
  end

  after(:all) do
    File.delete(@output_file) if File.exist?(@output_file)
  end

  context 'local Stats' do
    it 'should abort with bad git_dir' do
      expect do
        LocalStats.new(log_prefix: 'test', git_dir: '/blah/some_non_existent_dir')
      end.to raise_error SystemExit
    end

    it 'should abort with bad output file' do
      expect do
        LocalStats.new(log_prefix: 'test', git_dir: Dir.pwd)
      end.to raise_error SystemExit
    end

    it 'should abort with bad output file' do
      expect do
        LocalStats.new(log_prefix: 'test', git_dir: Dir.pwd)
      end.to raise_error SystemExit
    end

    it 'should abort with a output directory' do
      expect do
        LocalStats.new(log_prefix: 'test', git_dir: Dir.pwd, output_file: Dir.pwd)
      end.to raise_error SystemExit
    end

    it 'should abort with an invalid commit' do
      expect do
        LocalStats.new(@params.reject { |k, v| k == :commit })
      end.to raise_error SystemExit
    end

    it 'pass configuration with valid params' do
      expect do
        LocalStats.new(@params)
      end.not_to raise_error SystemExit
    end

    it 'should execute without error' do
      s = LocalStats.new(@params)
      expect(s).not_to receive(:remove_open_source)
      expect(s).to receive(:execute_stats_cmd).and_return(cloc: 'some stats')
      s.execute
    end
  end
end
