# frozen_string_literal: true

class Todo < ApplicationRecord
  include Searchable

  belongs_to :todo_list
  has_many :logs, as: :resourceable, class_name: 'EventLog'

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :description, analyzer: 'english', index_options: 'offsets'
    end
  end
end
