module API
  module V1
    class RateLimitAPI < Grape::API
      before { authenticate_user! }

      desc(
        'Get rate limit status',
        success: Entity::V1::APIRateLimit
      )
      get 'rate_limit' do
        error!('Only user authenticated with token has rate limit.', 403) unless token_user?

        discriminator = access_token.id
        counters = APIRateCounter.apis.map do |api_class|
          settings = api_class.const_get(:THROTTLE_SETTINGS)

          counter = APIRateCounter.counters.get(settings[:api_name], discriminator)
          counter ||= OpenStruct.new(
            limit: settings[:limit],
            remaining: settings[:limit],
            reset_at: Time.current + settings[:period]
          )
        end

        present counters, with: Entity::V1::APIRateLimit
      end
    end
  end
end
