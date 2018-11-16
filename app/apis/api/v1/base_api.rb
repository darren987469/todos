module API
  module V1
    class BaseAPI < Grape::API
      mount EventLogAPI
      mount RateLimitAPI
      mount TokenAPI
    end
  end
end
