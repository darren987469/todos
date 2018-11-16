class APIRateCounter
  PREFIX = 'grape:api_rate'.freeze

  class << self
    def redis
      @redis ||= ENV['REDIS_URL'] ? Redis.new(url: ENV['REDIS_URL']) : Redis.new
    end

    def counters
      @counters ||= APIRateCounter::Counters.new
    end
    delegate :get_or_add, :get, :clear, :key, to: :counters

    def apis
      [
        API::V1::EventLogAPI
      ].freeze
    end
  end

  attr_reader :api_name, :limit, :period, :discriminator

  def initialize(api_name:, limit:, period:, discriminator:)
    @api_name = api_name
    @limit = limit
    @period = period
    @discriminator = discriminator
  end

  def increment(amount = 1)
    @count = redis.incrby(key, amount)

    redis.expire(key, period) if reset_in == -1 # no expire

    @count
  end

  def count
    @count || 0
  end

  def reset_in
    redis.ttl(key) || period
  end

  def reset_at
    Time.current + reset_in
  end

  def remaining
    [(limit - count), 0].max
  end

  def key
    "#{PREFIX}:#{api_name}:#{discriminator}"
  end

  def redis
    self.class.redis
  end
end
