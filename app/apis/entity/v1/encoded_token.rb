module Entity
  module V1
    class EncodedToken < Token
      expose :encoded_token, documentation: { type: String, desc: 'Encoded access token.' }
    end
  end
end
