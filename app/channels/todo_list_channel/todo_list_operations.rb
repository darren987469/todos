# frozen_string_literal: true

class TodoListChannel
  class TodoListOperations < BaseOperations
    def create
      ActiveRecord::Base.transaction do
        todo_list = TodoList.create!(name: params[:name])
        todo_list.todo_listships.create!(user: current_user, role: :owner)

        log = create_log!(todo_list)
        broadcast(todo_list, log)
      end
    end

    def update(todo_list)
      authorize todo_list, :update?

      todo_list.update!(todo_list_params)

      log = create_log!(todo_list, changes: todo_list.previous_changes.except(:updated_at))
      broadcast(todo_list, log)
    end

    private

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end

    def create_log!(todo_list, changes: nil)
      ::EventLogger.log(
        resource: todo_list,
        user: current_user,
        action: action_name,
        tag: todo_list.log_tag,
        changes: changes
      )
    end

    def broadcast(todo_list, log)
      ActionCable.server.broadcast(
        stream_token,
        action: channel_action,
        todo_list: todo_list,
        log: log,
        errors: todo_list.errors.blank? ? nil : todo_list.errors.messages
      )
    end
  end
end
