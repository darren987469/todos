module TodoListsHelper
  def role_options
    roles = TodoListship.roles.keys - ['owner']
    roles.map { |role| [role.titleize, role] }
  end
end
