class TodoList < ApplicationRecord
  has_many :todos
  has_many :logs, as: :resourceable, class_name: 'EventLog'
  has_many :todo_listships, dependent: :delete_all, class_name: '::TodoListships'
  has_many :users, through: :todo_listships

  def owner
    users.merge(TodoListships.owner).first
  end

  def self.build(name:, user:)
    ActiveRecord::Base.transaction do
      todo_list = create!(name: name)
      todo_list.todo_listships.create!(user: user, role: :admin)
    end
  end
end
