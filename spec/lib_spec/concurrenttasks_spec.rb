require_relative '../spec_helper.rb'
RSpec.describe ConcurrentTasks do
  before(:all) do
    @dir = "#{Dir.pwd}/spec/fixtures/testdir"
    %w(dirone dirtwo dirthree).each do |d|
      FileUtils.mkdir_p("#{File.join(@dir, d)}")
    end
    @config = {
      'TOP_LVL_DIR' => @dir,
      'ORG_NAME' => 'TESTORG',
      'API_KEY' => 'TESTAPIKEY',
      'BLISS_HOST' => 'https://app.founderbliss.com'
    }
    @c = ConcurrentTasks.new(@config)
  end

  after(:all) do
    %w(dirone dirtwo dirthree).each do |d|
      FileUtils.rmdir(File.join(@dir, d))
    end
  end

  context 'given a configuration' do
    it 'has an org_name' do
      expect(@c.instance_variable_get('@org_name')).to eq('TESTORG')
    end

    it 'has an api key' do
      expect(@c.instance_variable_get('@api_key')).to eq('TESTAPIKEY')
    end

    it 'has a top level directory' do
      expect(@c.instance_variable_get('@top_level_dir')).to eq(@dir)
    end

    it 'has a bliss host' do
      expect(@c.instance_variable_get('@bliss_host')).to eq('https://app.founderbliss.com')
    end

    it 'has some repos' do
      expect(@c.instance_variable_get('@dirs_list').count).to eq(3)
    end
  end
end
