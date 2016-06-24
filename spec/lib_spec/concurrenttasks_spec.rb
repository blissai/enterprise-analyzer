require_relative '../spec_helper.rb'
RSpec.describe ConcurrentTasks do
  before do
    allow_any_instance_of(BlissLogger).to receive(:log_to_papertrail).and_return(true)
  end

  before(:all) do
    @dir = "#{Dir.pwd}/spec/fixtures/projs"
    `git clone https://github.com/founderbliss/homebrew-bliss-cli.git #{Dir.pwd}/spec/fixtures/projs/repoone`
    `git clone https://github.com/mikesive/sshlack.git #{Dir.pwd}/spec/fixtures/projs/repotwo`
    @config = {
      'TOP_LVL_DIR' => @dir,
      'ORG_NAME' => 'TESTORG',
      'API_KEY' => 'TESTAPIKEY'
    }
    @c = ConcurrentTasks.new(@config)
  end

  after(:all) do
    FileUtils.rm_rf("#{Dir.pwd}/spec/fixtures/projs/repoone")
    FileUtils.rm_rf("#{Dir.pwd}/spec/fixtures/projs/repotwo")
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

    it 'has some repos' do
      expect(@c.instance_variable_get('@dirs_list').count).to eq(2)
    end
  end
end
