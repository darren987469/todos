# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable
  devise :rememberable, :trackable, :validatable

  has_many :todo_listships, class_name: '::TodoListship'
  has_many :todo_lists, through: :todo_listships, class_name: '::TodoList'

  def full_name
    "#{first_name} #{last_name}"
  end
  alias name full_name

  def role_of(todo_list)
    todo_listships.where(todo_list_id: todo_list.to_param).first&.role&.inquiry
  end
end
