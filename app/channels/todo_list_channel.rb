class TodoListChannel < ApplicationCable::Channel
  attr_reader :params

  def subscribed
    stream_from "todo_list_#{params[:id]}"
  end

  def create(data)
    @action = 'create'
    @params = ActionController::Parameters.new data

    @todo = Todo.new(todo_params.merge(todo_list_id: params[:todo_list_id]))
    @todo.save

    create_log!
    broadcast
  end

  def update(data)
    @action = 'update'
    @params = ActionController::Parameters.new data

    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
    @todo.update(todo_params)

    create_log!(changes: @todo.previous_changes.except(:updated_at))
    broadcast
  end

  def destroy(data)
    @action = 'destroy'
    @params = ActionController::Parameters.new data

    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
    @todo.destroy

    create_log!
    broadcast
  end

  private
    def todo_params
      params.require(:todo).permit(:description, :complete, :id)
    end

    def broadcast
      ActionCable.server.broadcast("todo_list_#{params[:todo_list_id]}",
        action: @action,
        todo: @todo,
        log: @log,
        errors: @todo.errors.messages.presence
      )
    end

    def create_log!(options = {})
      return unless @todo.errors.messages.blank?

      @log = EventLog.create(
        resourceable: @todo,
        user: current_user,
        action: @action,
        description: "#{current_user.name} #{@action} a todo.",
        variation: options[:changes]
      )
    end
end
