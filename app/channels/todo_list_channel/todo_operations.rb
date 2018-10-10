# frozen_string_literal: true

class TodoListChannel
  class TodoOperations < BaseOperations
    def create
      todo = Todo.create(todo_params.merge(todo_list_id: params[:todo_list_id]))

      log = create_log!(todo)
      broadcast(todo, log)
    end

    def update
      todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
      todo.update(todo_params)

      log = create_log!(todo, changes: todo.previous_changes.except(:updated_at))
      broadcast(todo, log)
    end

    def destroy
      todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
      todo.destroy

      log = create_log!(todo)
      broadcast(todo, log)
    end

    private

    def todo_params
      params.require(:todo).permit(:description, :complete, :id, :archived_at)
    end

    def create_log!(todo, changes: nil)
      ::EventLogger.log(
        resource: todo,
        user: current_user,
        action: action_name,
        tag: "todo_list_#{todo.todo_list_id}",
        changes: changes
      )
    end

    def broadcast(todo, log)
      ActionCable.server.broadcast(
        stream_token,
        action: channel_action,
        todo: todo,
        log: log,
        errors: todo.errors.blank? ? nil : todo.errors.messages
      )
    end
  end
end
