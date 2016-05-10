require_relative '../spec_helper.rb'
RSpec.describe ExponentialBackoff do
  let(:backoff) do
    error = {
      NoMethodError => {
        rescuable: true,
        action: proc do
          puts 'response action'
        end
      }
    }
    ExponentialBackoff.new(2, error)
  end

  context 'exponential backoff' do
    it 'executes once' do
      backoff.run do
        puts 'hello'
      end
      expect(backoff.tried).to eq(1)
    end

    it 'executes twice' do
      backoff.run do
        puts 'running block now'
        null = nil
        null.empty?
      end
      expect(backoff.tried).to eq(3)
    end

    it 'ends execution if succeeds' do
      times = 0
      backoff.run do
        puts 'running block now'
        times += 1
        null = nil
        null.empty? if times < 2
      end
      expect(backoff.tried).to eq(2)
    end

    it 'doesnt rescue unknown error' do
      expect do
        backoff.run do
          puts 'running block now'
          null = nil
          throw ArgumentError
        end
      end.to raise_error(ArgumentError)
    end
  end
end
