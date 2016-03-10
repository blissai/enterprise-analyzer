RSpec.describe 'blisscollector.rb' do
  before(:all) do
    bliss_home = File.expand_path('~/bliss')
    FileUtils.mkdir_p(bliss_home)
    FileUtils.cp('.prospector.yml', bliss_home) unless File.exist?(File.join(bliss_home, '.prospector.yml'))
  end

  after(:all) do
  end

  it 'can run blisscollector with no failures over known repo' do
    require_relative '../blisscollector.rb'
  end
end
