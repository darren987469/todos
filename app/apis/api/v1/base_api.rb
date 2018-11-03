module API
  module V1
    class BaseAPI < Grape::API
      mount EventLogAPI
      mount TokenAPI
    end
  end
end
