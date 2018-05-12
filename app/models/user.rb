class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :todo_listships, class_name: '::TodoListships'
  has_many :todo_lists, through: :todo_listships, class_name: '::TodoList'

  def full_name
    "#{first_name} #{last_name}"
  end
  alias name full_name
end
