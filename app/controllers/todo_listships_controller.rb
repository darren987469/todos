# frozen_string_literal: true

class TodoListshipsController < ApplicationController
  def create
    authorize todo_list, :invite_member?

    member = User.find_by!(email: params[:email])

    ActiveRecord::Base.transaction do
      todo_list.todo_listships.create!(user: member, role: :user)
      log = ::EventLogger.log(
        resource: todo_list,
        user: current_user,
        action: 'create',
        description: "#{current_user.name} add a member #{member.name} to todo list.",
        tag: todo_list.log_tag
      )
    end
  rescue Pundit::NotAuthorizedError
    flash[:alert] = 'You cannot add member.'
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'No user.'
  ensure
    redirect_to edit_todo_list_path(@todo_list)
  end

  def destroy
    authorize todo_listship, :delete?

    ActionCable.server.broadcast(@todo_list.log_tag,
                                 action: 'delete_member',
                                 member: { id: @todo_listship.user_id },
                                 todo_list: @todo_list)

    @todo_listship.destroy
  rescue Pundit::NotAuthorizedError
    flash[:alert] = 'You cannot perform this action.'
  ensure
    redirect_to edit_todo_list_path(@todo_list)
  end

  private

  def todo_list
    @todo_list ||= current_user.todo_lists.find(params[:todo_list_id])
  end

  def todo_listship
    @todo_listship ||= todo_list.todo_listships.find(params[:id])
  end
end
