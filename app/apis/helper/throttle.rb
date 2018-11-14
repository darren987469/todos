module Helper
  module Throttle
    def throttle(api_name, limit:, period:)
      return unless token_user?

      counter = APIRateCounter.add(api_name, limit, period)
      count = counter.increment

      return unless count > limit

      header('X-RateLimit-Limit', limit)
      header('X-RateLimit-Remaining', counter.remaining)
      header('X-RateLimit-Reset', counter.reset_at.to_i)

      raise RateLimitExceededError
    end
  end
end
