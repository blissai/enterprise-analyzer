require_relative '../spec_helper'
RSpec.describe DirectoryAnalyzer do
  before(:all) do
    @git_dir = "#{Dir.pwd}/spec/fixtures/projs/ruby"
  end

  it 'has a correct line count' do
    d = DirectoryAnalyzer.new(@git_dir)
    expect(d.total_lines).to eq(5)
  end

  it 'correctly determines not too bigness' do
    d = DirectoryAnalyzer.new(@git_dir)
    expect(d.too_big?).to eq(false)
  end

  it 'correctly determines too bigness' do
    d = DirectoryAnalyzer.new(@git_dir, 2)
    expect(d.too_big?).to eq(true)
  end
end
