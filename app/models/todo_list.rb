class TodoList < ApplicationRecord
  has_many :todos
  has_many :logs, as: :resourceable, class_name: 'EventLog'
end
