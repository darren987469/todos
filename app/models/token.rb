class Token < ApplicationRecord
  SCOPE_OPTIONS = %w[read:log write:log].freeze

  belongs_to :user, optional: true

  def payload
    {
      id: id,
      scopes: scopes
    }
  end
end
