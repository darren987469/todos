class TodoListPolicy < ApplicationPolicy
  def update?
    role = user.role_of(todo_list)
    role.owner? || role.admin?
  end

  def invite_member?
    role = user.role_of(todo_list)
    role.owner? || role.admin?
  end

  def delete?
    user.role_of(todo_list).owner?
  end

  private

  def todo_list
    record
  end
end
