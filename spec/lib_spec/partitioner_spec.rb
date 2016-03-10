require_relative '../spec_helper'
RSpec.describe Partitioner do
  before(:all) do
    @logger = BlissLogger.new(nil, nil, 'partitionerspec')
    @git_dir = "#{Dir.pwd}/spec/fixtures/projs/ruby"
  end

  it 'can create partition files' do
    partitioner = Partitioner.new(@git_dir, @logger)
    partitioner.create_partitions
    expect(partitioner.create_partitions.size).to eq(1)
    expect(partitioner.partition_dirs.first).to eq(@git_dir)
  end
end
