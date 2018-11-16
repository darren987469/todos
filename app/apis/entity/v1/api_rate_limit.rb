module Entity
  module V1
    class APIRateLimit < Grape::Entity
      expose :api_name, documentation: { type: String, desc: 'Name of the api.' }
      expose :limit, documentation: { type: Integer, desc: 'The maximum number of requests you\'re permitted to make per hour.' }
      expose :remaining, documentation: { type: Integer, desc: 'The number of requests remaining in the current rate limit window.' }
      expose :reset_at, documentation: { type: Integer, desc: 'The time at which the current rate limit window resets in UTC epoch seconds.' }

      def reset_at
        object.reset_at.to_i
      end
    end
  end
end
