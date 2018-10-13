class TodoListshipPolicy < ApplicationPolicy
  def delete?
    return false unless user.id != todo_listship.user_id

    user_role = user.role_of(todo_list)
    permission_of(user_role) > permission_of(todo_listship.role)
  end

  private

  def todo_listship
    record
  end

  def todo_list
    todo_listship.todo_list
  end

  def permission_of(role)
    TodoListship.roles[role]
  end
end
