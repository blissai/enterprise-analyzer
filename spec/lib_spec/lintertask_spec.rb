require_relative '../spec_helper.rb'
RSpec.describe LinterTask do
  before(:all) do
    FileUtils.mkdir_p('vendor')
    `git clone https://github.com/sindresorhus/jshint-json.git vendor/jshint-json`
    @dir = "#{Dir.pwd}/spec/fixtures/projs/jqcarousel"
    `git clone https://github.com/mikesive/carouselJq.git #{@dir}`
    @repos = JSON.parse(File.read("#{Dir.pwd}/spec/fixtures/projs/.bliss.json"))
    @linter = {
      'quality_command' => 'jshint --reporter vendor/jshint-json/json.js git_dir > file_name'
    }

  end

  after(:all) do
    FileUtils.rm_rf(@dir)
    FileUtils.rm_rf('vendor')
    FileUtils.rm_rf('file')
  end

  let(:linter_task) do
    LinterTask.new(@dir, 'TESTAPIKEY', 'https://app.founderbliss.com', @repos['jqcarousel'])
  end

  context 'given a configuration' do
    it 'has an org_name' do
      expect(linter_task.instance_variable_get('@organization')).to eq('mikesive')
    end

    it 'has an api key' do
      expect(linter_task.instance_variable_get('@api_key')).to eq('TESTAPIKEY')
    end

    it 'has a top level directory' do
      expect(linter_task.instance_variable_get('@git_dir')).to eq(@dir)
    end

    it 'has a bliss host' do
      expect(linter_task.instance_variable_get('@host')).to eq('https://app.founderbliss.com')
    end

    it 'has some repos' do
      expect(linter_task.instance_variable_get('@agent').class).to eq(Mechanize)
    end
  end

  context 'given a linter' do
    it 'should format the linter command' do
      command = linter_task.lint_command(@linter, "#{@dir}/testfile.json")
      expect(command).to eq("jshint --reporter vendor/jshint-json/json.js #{@dir} > #{@dir}/testfile.json")
    end

    it 'should run the linter' do
      file_name = "#{@dir}/testfile.json"
      cmd = "jshint --reporter vendor/jshint-json/json.js #{@dir} > #{file_name}"
      linter_task.execute_linter_cmd(cmd, file_name, 'jshint', 1)
      partition = File.read(file_name).split("<--LintFilePartition-->\n")
                      .find { |lfs| !lfs.empty? }
      result = JSON.parse(partition)
      expect(result['result']).to_not eq(nil)
    end
  end

  context 'given a bad command' do
    it 'should throw a Errno::ENOENT exception when the linter doesn\'t exist' do
      cmd = 'not a valid command'
      file_name = "#{@dir}/testfile.json"
      expect { linter_task.execute_linter_cmd(cmd, file_name, 'test-linter', 1) }.to raise_error(Errno::ENOENT)
    end

    it 'should throw a LinterError when the linter exits with a bad status' do
      cmd = "echo 'test exit message' 1>&2 && exit 1"
      expect { linter_task.execute_linter_cmd(cmd, 'file', 'test-linter', 1) }.to raise_error(LinterError, /test exit message/)
    end

    it 'should catch a LinterError when thrown' do
      allow(linter_task).to receive(:execute_linter_cmd).and_raise(LinterError, 'test')
      allow(linter_task.instance_variable_get('@logger')).to receive(:http_post).and_return('log')
      expect(linter_task.lint_commit(@linter, '/test.txt')).to eq('log')
    end
  end
end
