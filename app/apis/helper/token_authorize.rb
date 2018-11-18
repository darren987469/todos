module Helper
  module TokenAuthorize
    def authorize_with_token(scope)
      scopes = access_token&.scopes || []
      scope.in?(scopes) || (raise Pundit::NotAuthorizedError)
    end
  end
end
