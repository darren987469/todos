class Token < ApplicationRecord
  SCOPE_OPTIONS = %w[read:log write:log].freeze

  belongs_to :user, optional: true

  def payload
    {
      id: id,
      scopes: scopes
    }
  end

  def encoded_token
    JSONWebToken.encode(payload)
  end
end
