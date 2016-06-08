# execute a block whilst exponentially backing off when failures occur
class ExponentialBackoff
  attr_reader :max_tries
  attr_reader :tried

  def initialize(max_tries = 5, rescuable = {})
    @rescuable = rescuable
    @tried = 0
    @max_tries = max_tries
  end

  def run(&code)
    @tried += 1
    yield
  rescue Exception => e
    if @tried <= @max_tries
      sleep(2**@tried)
      run(&code) if should_rescue?(e)
    else
      puts 'Tried max number of times.'.red
    end
  end

  private

  def default_rescue?
    if @rescuable.empty?
      puts 'Task failed. Trying again...'.yellow
      return true
    end
    false
  end

  def rescuable?(e)
    @rescuable.each do |t, v|
      if e.is_a? t
        v[:action].call
        return v[:rescuable]
      end
    end
    raise e
  end

  def should_rescue?(e)
    default_rescue? || rescuable?(e)
  end
end
