require_relative '../spec_helper'
RSpec.describe Partitioner do
  before do
    allow_any_instance_of(BlissLogger).to receive(:log_to_papertrail).and_return(true)
  end

  before(:all) do
    @logger = BlissLogger.new(nil, nil, 'partitionerspec')
    @git_dir = "#{Dir.pwd}/spec/fixtures/projs/ruby"
  end

  it 'can create partition files' do
    partitioner = Partitioner.new(@git_dir, @logger, { 'partitionable' => true, 'max_lines' => 1 })
    partitioner.create_partitions
    expect(partitioner.partition_dirs.first).not_to eq(@git_dir)
    expect(partitioner.partition_dirs.first).to include('/tmp/parts')
    # expect(partitioner.create_partitions.size).to eq(2)
  end


  it 'doesnt create partition files' do
    partitioner = Partitioner.new(@git_dir, @logger, 'partitionable' => false, 'max_lines' => 1)
    expect(partitioner.create_partitions.size).to eq(1)
    expect(partitioner.partition_dirs.first).to eq(@git_dir)
  end


  it 'shouldnt create partition files' do
    partitioner = Partitioner.new(@git_dir, @logger, 'partitionable' => true)
    expect(partitioner.create_partitions.size).to eq(1)
    expect(partitioner.partition_dirs.first).to eq(@git_dir)
  end
end
