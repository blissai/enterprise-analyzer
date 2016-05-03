require_relative '../spec_helper'
RSpec.describe Partitioner do
  before(:all) do
    @logger = BlissLogger.new(nil, nil, 'partitionerspec')
    @git_dir = "#{Dir.pwd}/spec/fixtures/projs/ruby"
    puts "\n\n#{@git_dir}\n\n"
  end

  it 'can create partition files' do
    partitioner = Partitioner.new(@git_dir, @logger, { 'partitionable' => true, 'max_lines' => 1 }, 100)
    expect(partitioner.create_partitions.size).to eq(2)
    # expect(partitioner.partition_dirs.first).to eq(@git_dir)
  end


  it 'doesnt create partition files' do
    partitioner = Partitioner.new(@git_dir, @logger, { 'partitionable' => false, 'max_lines' => 1 })
    expect(partitioner.create_partitions.size).to eq(1)
    expect(partitioner.partition_dirs.first).to eq(@git_dir)
  end


  it 'shouldnt create partition files' do
    partitioner = Partitioner.new(@git_dir, @logger, { 'partitionable' => true })
    expect(partitioner.create_partitions.size).to eq(1)
    expect(partitioner.partition_dirs.first).to eq(@git_dir)
  end
end
