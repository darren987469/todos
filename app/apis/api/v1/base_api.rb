module API
  module V1
    class BaseAPI < Grape::API
      mount EventLogAPI
    end
  end
end