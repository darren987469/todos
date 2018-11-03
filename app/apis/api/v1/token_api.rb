module API
  module V1
    class TokenAPI < Grape::API
      format :json

      resource 'tokens' do
        desc 'Create token' do
          success Entity::V1::EncodedToken
        end
        params do
          requires :note, Entity::V1::Token.documentation[:note]
          requires :scopes, Entity::V1::Token.documentation[:scopes]
        end
        post do
          attributes = declared(params)
          attributes[:scopes] = attributes[:scopes].uniq
          token = current_user.tokens.create!(attributes)

          present token, with: Entity::V1::EncodedToken
        end
      end
    end
  end
end
