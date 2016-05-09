require_relative '../spec_helper.rb'
RSpec.describe Status do
  let(:status) do
    s = Status.new('testrepokey', 'testcommit')
    allow(s).to receive(:http_post).and_return(success: 'ok')
    allow(s).to receive(:wait)
    s
  end

  context 'given a configuration' do
    it 'at least pings' do
      expect(status).to receive(:http_post)
      status.run
      status.finish
    end

    it 'pings on a thread' do
      expect(status).to receive(:http_post).at_least(2).times
      status.run
      sleep 1
      status.finish
    end

    it 'kills the thread' do
      expect(Thread).to receive(:kill)
      status.run
      status.finish
    end
  end
end
