module Helper
  module Base
    def authenticate_user!
      current_user || (raise NotAuthenticatedError)
    end

    def current_user
      devise_user || token_user
    end
  end
end
