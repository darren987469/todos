class APIRateCounter
  PREFIX = 'grape:api_rate'.freeze

  class << self
    def redis
      @redis ||= ENV['REDIS_URL'] ? Redis.new(url: ENV['REDIS_URL']) : Redis.new
    end

    def apis
      @apis ||= {}
    end

    def add(api_name, limit, period)
      apis[api_name] ||= new(api_name, limit, period)
    end
  end

  attr_reader :api_name, :limit, :period, :count

  def initialize(api_name, limit, period)
    @api_name = api_name
    @limit = limit
    @period = period
  end

  def increment(amount = 1)
    @count = redis.incrby(key, amount)

    redis.expire(key, period) if reset_in == -1 # no expire

    @count
  end

  def reset_in
    redis.ttl(key)
  end

  def reset_at
    Time.current + reset_in
  end

  def remaining
    [(limit - count), 0].max
  end

  def key
    "#{PREFIX}:#{api_name}"
  end

  def redis
    self.class.redis
  end
end
