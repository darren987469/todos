class TodoListChannel < ApplicationCable::Channel
  attr_reader :params

  class UnknownAction < StandardError; end
  class NotAuthorizedError < StandardError; end

  VALID_ACTION = %w( add_member create_todo_list update_todo_list destroy_todo_list
    create_todo update_todo destroy_todo )

  def subscribed
    @stream_token = "todo_list_#{params[:id]}"
    stream_from @stream_token
  end

  def request(data)
    @params = ActionController::Parameters.new data
    @action = params[:method]
    raise UnknownAction unless VALID_ACTION.include?(@action)

    self.send(@action)
  rescue ActiveRecord::RecordNotFound
    broadcast_errors(['RecordNotFound'])
  rescue NotAuthorizedError
    broadcast_errors(['Forbidden'])
  rescue StandardError => e
    broadcast_errors(['500 Error'])
    raise if Rails.env.development?
  end

  private

  def add_member
    @todo_list = current_user.todo_lists.find(params[:id])
    @member = User.find_by_email(params[:email])
    raise ActiveRecord::RecordNotFound unless @member.present?

    todo_listship = @todo_list.todo_listships.new(user: @member, role: :user)
    ActiveRecord::Base.transaction do
      todo_listship.save
      create_log!(@todo_list) if todo_listship.errors.blank?
    end

    ActionCable.server.broadcast(@stream_token,
      action: @action,
      member: @member,
      log: @log,
      errors: todo_listship.errors.messages.presence
    )
    clear_assigned_instance_variables!
  end

  def create_todo_list
    ActiveRecord::Base.transaction do
      @todo_list = TodoList.new(name: "List #{current_user.todo_lists.count + 1}",)
      if @todo_list.save
        @todo_list.todo_listships.create!(user: current_user, role: :owner)
      end
    end

    create_log!(@todo_list)
    broadcast(@todo_list)
  end

  def update_todo_list
    raise NotImplementedError
    @action = 'update_todo_list'
  end

  def destroy_todo_list
    @todo_list = current_user.todo_lists.find(params[:id])
    raise NotAuthorizedError unless @todo_list.owner == current_user

    @todo_list.destroy

    create_log!(@todo_list)
    broadcast(@todo_list)
  end

  def create_todo
    @todo = Todo.new(todo_params.merge(todo_list_id: params[:todo_list_id]))
    @todo.save

    create_log!(@todo)
    broadcast(@todo)
  end

  def update_todo
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
    @todo.update(todo_params)

    create_log!(@todo, changes: @todo.previous_changes.except(:updated_at))
    broadcast(@todo)
  end

  def destroy_todo
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
    @todo.destroy

    create_log!(@todo)
    broadcast(@todo)
  end

  def todo_params
    params.require(:todo).permit(:description, :complete, :id, :archived_at)
  end

  def broadcast(resource)
    ActionCable.server.broadcast(@stream_token,
      action: @action,
      todo_list: @todo_list,
      todo: @todo,
      log: @log,
      errors: resource.errors.messages.presence
    )
    clear_assigned_instance_variables!
  end

  def broadcast_errors(errors)
    ActionCable.server.broadcast("todo_list_#{params[:todo_list_id]}", errors: errors)
    clear_assigned_instance_variables!
  end

  # make sure not to access outdated data
  def clear_assigned_instance_variables!
    @params, @action = nil, nil
    @todo_list, @todo = nil, nil
    @member = nil
    @log = nil
  end

  def create_log!(resource, description: nil, tag: nil, changes: nil)
    return unless resource.errors.messages.blank?

    resource_action =
      case @action
      when 'add_member'
        description = "#{current_user.name} add a member #{@member.name} to todo list."
        'create'
      when 'create_todo_list', 'create_todo'
        'create'
      when 'update_todo_list', 'update_todo'
        changes[:archived_at] ? 'archive' : 'update'
      when 'destroy_todo_list', 'destroy_todo_list'
        'destroy'
      end

    @log = ::EventLogger.log(
      resource: resource,
      user: current_user,
      action: resource_action,
      description: description,
      tag: tag || @todo_list ? @todo_list.log_tag : "todo_list_#{@todo.todo_list_id}",
      changes: changes,
    )
  end
end
