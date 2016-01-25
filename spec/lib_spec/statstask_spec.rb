require_relative '../spec_helper.rb'
RSpec.describe StatsTask do
  before(:all) do
    @dir = "#{Dir.pwd}/spec/fixtures/testdir/bliss-test-php"
    @repos = JSON.parse(File.read("#{Dir.pwd}/spec/fixtures/testdir/.bliss.json"))
    @c = StatsTask.new(@dir, 'TESTAPIKEY', 'https://app.founderbliss.com', @repos['bliss-php-test'])
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
end
