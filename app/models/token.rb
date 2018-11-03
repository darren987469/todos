class Token < ApplicationRecord
  SCOPE_OPTIONS = %w[read:log write:log].freeze

  belongs_to :user

  def payload
    {
      id: id,
      scopes: scopes
    }
  end
end
