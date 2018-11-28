module Helper
  module Throttle
    def throttle(settings)
      return unless token_user?

      limit = settings[:limit]
      options = settings.merge(discriminator: access_token.user_id)
      counter = APIRateCounter.get_or_add(options)
      count = counter.increment

      header('X-RateLimit-Limit', limit)
      header('X-RateLimit-Remaining', counter.remaining)
      header('X-RateLimit-Reset', counter.reset_at.to_i)

      raise RateLimitExceededError if count > limit
    end
  end
end
