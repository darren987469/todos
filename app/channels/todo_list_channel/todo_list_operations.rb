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

    def destroy
      todo_list = current_user.todo_lists.find(params[:id])
      raise NotAuthorizedError unless todo_list.owner == current_user

      todo_list.destroy

      log = create_log!(todo_list)
      broadcast(todo_list, log)
    end

    private

    def create_log!(todo_list)
      ::EventLogger.log(
        resource: todo_list,
        user: current_user,
        action: action_name,
        tag: todo_list.log_tag
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
