module API
  module V1
    class RateLimitAPI < Grape::API
      before { token_authenticate! }

      desc(
        'Get rate limit status',
        tags: ['Public API'],
        success: Entity::V1::APIRateLimit,
        is_array: true
      )
      get 'rate_limit' do
        discriminator = access_token.id
        counters = APIRateCounter.apis.map do |api_class|
          settings = api_class.const_get(:THROTTLE_SETTINGS)

          counter_options = settings.merge(discriminator: discriminator)
          APIRateCounter.counters.get_or_add(counter_options)
        end

        present counters, with: Entity::V1::APIRateLimit
      end
    end
  end
end
