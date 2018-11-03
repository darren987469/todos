class JSONWebToken
  SECRET = Rails.application.secrets.secret_key_base
  ALGORITHM = 'HS256'.freeze

  class << self
    def encode(payload)
      JWT.encode(payload, SECRET, ALGORITHM)
    end

    def decode(token)
      body = JWT.decode(token, SECRET, true, algorithm: ALGORITHM)[0]
      HashWithIndifferentAccess.new body
    rescue StandardError => _error
      nil
    end
  end
end
