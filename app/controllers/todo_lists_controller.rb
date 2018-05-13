class TodoListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @todo_list = current_user.todo_lists.first
    @todo_list = TodoList.build(name: 'New Todo List', user: current_user) if @todo_list.blank?

    redirect_to todo_list_path(@todo_list)
  end

  def show
    @todo_lists = current_user.todo_lists
    @todo_list = @todo_lists.find { |todo_list| todo_list.id == params[:id].to_i }
    raise ActiveRecord::RecordNotFound unless @todo_list.present?

    @todos = @todo_list.todos.active.order(id: :asc)
    @logs = EventLog.where(tag: @todo_list.log_tag).order(id: :desc).limit(10)
  end

  def edit
    @todo_list = current_user.todo_lists.find(params[:id])
    @todo_listship = @todo_list.todo_listships.new
    @users = @todo_list.users.includes(:todo_listships).where(todo_listships: { todo_list_id: @todo_list.id })
  end

  def update
    @todo_list = current_user.todo_lists.find(params[:id])

    current_user_role = current_user.role_of(@todo_list)
    unless (current_user_role.owner? || current_user_role.admin?)
      flash[:alert] = 'You cannot update this todo list.'
      return redirect_to todo_list_path(@todo_list)
    end

    @todo_list.update!(todo_list_params)
    flash[:notice] = 'Name is updated!'
    redirect_to edit_todo_list_path(@todo_list)
  end

  def destroy
    @todo_list = current_user.todo_lists.find(params[:id])

    unless current_user.role_of(@todo_list).owner?
      flash[:alert] = 'You cannot delete this todo list.'
      return redirect_to edit_todo_list_path(@todo_list)
    end

    @todo_list.destroy!
    flash[:notice] = "List #{@todo_list.name} is deleted!"
    redirect_to todo_lists_path
  end

  private
    def todo_list_params
      params.require(:todo_list).permit(:name)
    end
end
