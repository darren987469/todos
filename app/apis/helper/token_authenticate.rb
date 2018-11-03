module Helper
  module TokenAuthenticate
    def token_authenticate
      return nil unless decoded_auth_token

      Token.find_by(id: decoded_auth_token[:id])
    end

    def token_authenticate!
      access_token || (raise NotAuthenticatedError)
    end

    def access_token
      @access_token ||= token_authenticate
    end

    def token_user
      @token_user ||= access_token ? access_token.user : nil
    end

    def decoded_auth_token
      @decoded_auth_token ||= auth_token.nil? ? nil : JSONWebToken.decode(auth_token)
    end

    def auth_token
      @auth_token ||= headers['Authorization']&.scan(/\Atoken\s(.*)\z/)&.flatten&.first
    end
  end
end
