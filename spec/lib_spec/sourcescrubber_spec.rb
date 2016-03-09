require_relative '../spec_helper.rb'
RSpec.describe CollectorTask do
  before(:all) do
    @scrubber = SourceScrubber.new
    @unscrubbed = File.read('spec/fixtures/cpd-lintfile.xml')
    @scrubbed = File.read('spec/fixtures/cpd-scrubbed.xml')
    @unscrubbed_partitioned = File.read('spec/fixtures/cpd-lintfile-partitioned.xml')
    @scrubbed_partitioned = File.read('spec/fixtures/cpd-scrubbed-partitioned.xml')
  end

  it 'scrubs out codefragment elements from partitioned cpd xml' do
    expect(
      @scrubber.scrub(@unscrubbed).delete("\n")
    ).to eq(@scrubbed.delete("\n"))
  end

  it 'scrubs out codefragment elements from partitioned cpd xml' do
    expect(
      @scrubber.scrub(@unscrubbed_partitioned).delete("\n")
    ).to eq(@scrubbed_partitioned.delete("\n"))
  end
end
