class TodoListshipsController < ApplicationController
  def create
    @todo_list = current_user.todo_lists.find(params[:todo_list_id])

    current_user_role = current_user.role_of(@todo_list)
    unless (current_user_role.admin? || current_user_role.owner?)
      flash[:alert] = 'You cannot add member.'
      return redirect_to edit_todo_list_path(@todo_list)
    end

    @member = User.find_by_email(params[:email])
    if @member.blank?
      flash[:alert] = 'No user.'
      return redirect_to edit_todo_list_path(@todo_list)
    end

    ActiveRecord::Base.transaction do
      @todo_list.todo_listships.create!(user: @member, role: :user)
      @log = ::EventLogger.log(
        resource: @todo_list,
        user: current_user,
        action: 'create',
        description: "#{current_user.name} add a member #{@member.name} to todo list.",
        tag: @todo_list.log_tag
      )
    end

    redirect_to edit_todo_list_path(@todo_list)
  end

  def destroy
    @todo_listship = TodoListship.find(params[:id])
    if @todo_listship.user_id == current_user.id
      flash[:alert] = 'You cannot delete yourself.'
      return redirect_to edit_todo_list_path(params[:todo_list_id])
    end

    current_user_role = TodoListship.where(user: current_user, todo_list_id: params[:todo_list_id]).first&.role
    raise ActiveRecord::RecordNotFound unless current_user_role.present?

    unless permission_of(current_user_role) > permission_of(@todo_listship.role)
      flash[:alert] = 'You cannot delete this member.'
      return redirect_to edit_todo_list_path(params[:todo_list_id])
    end

    @todo_listship.destroy
    redirect_to edit_todo_list_path(params[:todo_list_id])
  end

  private
    def permission_of(role)
      TodoListship.roles[role]
    end
end
