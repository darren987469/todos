module Entity
  module V1
    class EncodedToken < Token
      expose :encoded_token, documentation: { type: String, desc: 'Encoded access token.' }

      def encoded_token
        JSONWebToken.encode(object.payload)
      end
    end
  end
end
