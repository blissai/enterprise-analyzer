require_relative '../spec_helper.rb'
RSpec.describe CollectorTask do
  before(:all) do
    @dir = "#{Dir.pwd}/spec/fixtures/projs"
    `git clone https://github.com/founderbliss/homebrew-bliss-cli.git #{Dir.pwd}/spec/fixtures/projs/repoone`
    @config = {
      'TOP_LVL_DIR' => @dir,
      'ORG_NAME' => 'TESTORG',
      'API_KEY' => 'TESTAPIKEY'
    }
    @c = CollectorTask.new(@config)
  end

  after(:all) do
    FileUtils.rm_rf("#{Dir.pwd}/spec/fixtures/projs/repoone")
  end

  context 'given a configuration' do
    it 'has an org_name' do
      expect(@c.instance_variable_get('@org_name')).to eq('TESTORG')
    end

    it 'has an api key' do
      expect(@c.instance_variable_get('@api_key')).to eq('TESTAPIKEY')
    end

    it 'has a top level directory' do
      expect(@c.instance_variable_get('@top_lvl_dir')).to eq(@dir)
    end

    it 'has a bliss host' do
      expect(@c.instance_variable_get('@host')).to eq('https://blissai.com')
    end

    it 'has some repos' do
      expect(@c.instance_variable_get('@saved_repos').count).to eq(7)
    end
  end

  context 'given a repo' do
    it 'identifies a new repo' do
      expect(@c.new_repo?('notinthefile')).to eq(true)
    end

    it 'identifies an old repo' do
      expect(@c.new_repo?('ruby')).to eq(false)
    end

    it 'identifies a repo that has new commits' do
      expect(@c.needs_running?('ruby', 'notadigest')).to eq(true)
    end

    it 'identifies a repo that doesn\'t have new commits' do
      expect(@c.needs_running?('ruby', 'hereisadigest')).to eq(false)
    end

    it 'identifies the directories' do
      list = @c.get_directory_list(@dir)
      expect(list.size).to eq(1)
    end
  end
end
