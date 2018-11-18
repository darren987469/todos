module API
  module V1
    class TokenAPI < Grape::API
      format :json

      resource 'tokens' do
        desc(
          'Get tokens',
          tags: ['Internal API'],
          success: Entity::V1::Token,
          is_array: true
        )
        get do
          tokens = current_user.tokens

          present tokens, with: Entity::V1::Token
        end

        desc(
          'Get token',
          tags: ['Internal API'],
          success: Entity::V1::Token
        )
        get ':id' do
          token = current_user.tokens.find(params[:id])

          present token, with: Entity::V1::Token
        end

        desc(
          'Create token',
          tags: ['Internal API'],
          success: Entity::V1::EncodedToken
        )
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

        desc(
          'Update token',
          tags: ['Internal API'],
          success: Entity::V1::Token
        )
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

        desc(
          'Delete token',
          tags: ['Internal API'],
          success: Entity::V1::EncodedToken
        )
        delete ':id' do
          token = current_user.tokens.find(params[:id])
          token.destroy

          present token, with: Entity::V1::Token
        end
      end
    end
  end
end
