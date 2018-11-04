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

        desc 'Update token' do
          success Entity::V1::Token
        end
        params do
          optional :note, Entity::V1::Token.documentation[:note]
          optional :scopes, Entity::V1::Token.documentation[:scopes]
        end
        patch ':id' do
          token = current_user.tokens.find(params[:id])

          attributes = declared(params)
          attributes[:scopes] = attributes[:scopes].uniq
          token.assign_attributes(attributes)
          token.save if token.changed?

          present token, with: Entity::V1::Token
        end

        desc 'Delete token' do
          success Entity::V1::Token
        end
        delete ':id' do
          token = current_user.tokens.find(params[:id])
          token.destroy

          present token, with: Entity::V1::Token
        end
      end
    end
  end
end
