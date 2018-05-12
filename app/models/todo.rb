class Todo < ApplicationRecord
  belongs_to :todo_list
  has_many :logs, as: :resourceable, class_name: 'EventLog'
end
