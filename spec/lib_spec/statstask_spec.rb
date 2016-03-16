require_relative '../spec_helper.rb'
RSpec.describe StatsTask do
  before(:all) do
    @dir = "#{Dir.pwd}/spec/fixtures/projs/ruby"
    @repos = JSON.parse(File.read("#{Dir.pwd}/spec/fixtures/projs/.bliss.json"))
    @c = StatsTaskMock.new(@dir, 'TESTAPIKEY', 'https://app.founderbliss.com', @repos['ruby'])
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

    it 'calculates stats on the correct test directories' do
      @c.set_test_dirs
      cloc_tests = @c.cloc_tests(@dir)
      cloc_hash = YAML.load(cloc_tests)
      expect(cloc_hash['Ruby']['nFiles'].to_i).to eq(1)
    end

    it 'processes a commit, and returns a hash of cloc values' do
      result = @c.process_commit('test')
      expect(result[:added_lines]).to eq(4)
      expect(result[:deleted_lines]).to eq(3)
      expect(result[:total_cloc]).to include('nFiles')
      expect(result[:cloc]).to include('nFiles')
      expect(result[:cloc_tests]).to include('nFiles')
    end
  end
end
