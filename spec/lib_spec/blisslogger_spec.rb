require_relative '../spec_helper.rb'
RSpec.describe CollectorTask do
  before(:all) do
    @api_key = 'test'
    @repo_key = 'test'
    @b = BlissLogger.new(@api_key)
  end

  context 'given a configuration' do
    it 'should have an api_key set' do
      expect(@b.instance_variable_get('@api_key')).to eq('test')
    end

    it 'should set a repo key' do
      @b.repo_key(@repo_key)
      expect(@b.instance_variable_get('@repo_key')).to eq('test')
    end

    it 'should output success msg to stdout' do
      expect { @b.success('test_message') }.to output.to_stdout
    end

    it 'should output warn msg to stdout' do
      expect { @b.warn('test_message') }.to output.to_stdout
    end

    it 'should output info msg to stdout' do
      expect { @b.info('test_message') }.to output.to_stdout
    end

    it 'should output error msg to stdout' do
      expect { @b.error('test_message') }.to output.to_stdout
    end

    it 'should log to server' do
      r = @b.success('test')
      expect(r.key? 'success').to eq(true)
    end
  end
end
