module Entity
  module V1
    class Token < Grape::Entity
      expose :id
      expose :note, documentation: { type: String, desc: 'Token description', allow_blank: false }
      expose :scopes, documentation: {
        type: Array[String],
        desc: 'Scopes of the token.',
        allow_blank: false,
        values: ::Token::SCOPE_OPTIONS
      }
    end
  end
end
