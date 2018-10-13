# frozen_string_literal: true

class TodoListChannel
  class TodoListshipOperations < BaseOperations
    attr_reader :current_user, :params, :todo_list

    def initialize(current_user, params, todo_list)
      @current_user = current_user
      @params = params
      @todo_list = todo_list
    end

    class UserNotFound < StandardError; end

    def create
      authorize todo_list, :invite_member?

      member = User.find_by(email: params[:email])
      raise UserNotFound unless member.present?

      todo_listship = todo_list.todo_listships.create!(user: member, role: params[:role])
      log = ::EventLogger.log(
        resource: todo_listship,
        user: current_user,
        action: 'create',
        description: "#{current_user.name} add member #{member.name} to todo list.",
        tag: todo_list.log_tag
      )
      ActionCable.server.broadcast(
        todo_list.log_tag,
        action: 'add_member',
        member: member,
        log: log
      )
    end

    def update
      todo_listship = todo_list.todo_listships.find(params[:id])
      todo_listship.role = params[:role]
      authorize todo_listship, :update?

      todo_listship.save!

      member = todo_listship.user
      log = ::EventLogger.log(
        resource: todo_listship,
        user: current_user,
        action: 'update',
        description: "#{current_user.name} change member #{member.name} to #{params[:role]} of the todo list.",
        tag: todo_list.log_tag,
        changes: todo_listship.previous_changes.except(:updated_at)
      )
      ActionCable.server.broadcast(
        todo_list.log_tag,
        action: 'update_member',
        member: member,
        todo_listship: todo_listship,
        log: log
      )
    end

    def destroy
      todo_listship = todo_list.todo_listships.find(params[:id])
      authorize todo_listship, :delete?

      todo_listship.destroy

      member = todo_listship.user
      log = ::EventLogger.log(
        resource: todo_listship,
        user: current_user,
        action: 'destroy',
        description: "#{current_user.name} delete member #{member.name} from todo list.",
        tag: todo_list.log_tag
      )
      ActionCable.server.broadcast(
        todo_list.log_tag,
        action: 'delete_member',
        member: member,
        log: log
      )
    end
  end
end
