class Token < ApplicationRecord
  belongs_to :user

  serialize :scopes
end
