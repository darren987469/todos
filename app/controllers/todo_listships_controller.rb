class TodoListshipsController < ApplicationController
  def create
    @todo_list = current_user.todo_lists.find(params[:todo_list_id])

    current_user_role = current_user.role_of(@todo_list)
    unless (current_user_role.admin? || current_user_role.owner?)
      flash[:alert] = 'You can not add member.'
      return redirect_to edit_todo_list_path(@todo_list)
    end

    @member = User.find_by_email(params[:email])
    raise ActiveRecord::RecordNotFound unless @member.present?

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
end
