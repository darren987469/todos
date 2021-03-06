# frozen_string_literal: true

class TodoListship < ApplicationRecord
  belongs_to :user
  belongs_to :todo_list

  enum role: { owner: 2000, admin: 1000, user: 0 }, _prefix: true
end
