class Todo < ApplicationRecord
  belongs_to :todo_list
  has_many :logs, as: :resourceable, class_name: 'EventLog'

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil ) }
end
