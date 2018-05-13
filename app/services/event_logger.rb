class EventLogger
  VALID_ACTION = %w( create update destroy )

  class << self
    # == Example usage:
    #   todo = Todo.create
    #   EventLogger.log(resource: todo, user: current_user, action: :create)
    #   => #<EventLog id: 1, resourceable_type: "Todo", resourceable_id: 1, user_id: 1, tag: "todo_1", action: "create", description: "Someone create a todo", variation: nil, ...>
    def log(resource:, user:, action:, tag: nil, description: nil, changes: nil)
      raise ArgumentError unless VALID_ACTION.include?(action.to_s)

      resource_name = resource.class.to_s.downcase
      EventLog.create!(
        resourceable: resource,
        user: user,
        action: action,
        tag: tag || "#{resource_name}_#{resource.to_param}",
        description: description || "#{user.name} #{action} a #{resource_name}",
        variation: changes
      )
    end
  end
end
