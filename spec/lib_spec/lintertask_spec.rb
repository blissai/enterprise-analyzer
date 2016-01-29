require_relative '../spec_helper.rb'
RSpec.describe LinterTask do
  before(:all) do
    FileUtils.mkdir_p('vendor')
    `git clone https://github.com/sindresorhus/jshint-json.git vendor/jshint-json`
    @dir = "#{Dir.pwd}/spec/fixtures/projs/jqcarousel"
    `git clone https://github.com/mikesive/carouselJq.git #{@dir}`
    @repos = JSON.parse(File.read("#{Dir.pwd}/spec/fixtures/projs/.bliss.json"))
    @c = LinterTask.new(@dir, 'TESTAPIKEY', 'https://app.founderbliss.com', @repos['jqcarousel'])

    @linter = {
      'quality_command' => 'jshint --reporter vendor/jshint-json/json.js git_dir > file_name'
    }
  end

  after(:all) do
    FileUtils.rm_rf(@dir)
    FileUtils.rm_rf('vendor')
  end

  context 'given a configuration' do
    it 'has an org_name' do
      expect(@c.instance_variable_get('@organization')).to eq('mikesive')
    end

    it 'has an api key' do
      expect(@c.instance_variable_get('@api_key')).to eq('TESTAPIKEY')
    end

    it 'has a top level directory' do
      expect(@c.instance_variable_get('@git_dir')).to eq(@dir)
    end

    it 'has a bliss host' do
      expect(@c.instance_variable_get('@host')).to eq('https://app.founderbliss.com')
    end

    it 'has some repos' do
      expect(@c.instance_variable_get('@agent').class).to eq(Mechanize)
    end
  end

  context 'given a linter' do
    it 'should format the linter command' do
      command = @c.lint_command(@linter, "#{@dir}/testfile.json")
      expect(command).to eq("jshint --reporter vendor/jshint-json/json.js #{@dir} > #{@dir}/testfile.json")
    end

    it 'should run the linter' do
      file_name = "#{@dir}/testfile.json"
      cmd = "jshint --reporter vendor/jshint-json/json.js #{@dir} > #{file_name}"
      result = @c.execute_linter_cmd(cmd, file_name)
      expect(result).to_not eq('')
    end
  end
end
