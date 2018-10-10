# frozen_string_literal: true

class TodoListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_list, only: %i[show edit update destroy]
  before_action :check_update_permission, only: [:update]
  before_action :check_destroy_permission, only: [:destroy]

  def index
    @todo_list = current_user.todo_lists.first
    @todo_list = TodoList.build(name: 'New Todo List', user: current_user) if @todo_list.blank?

    redirect_to todo_list_path(@todo_list)
  end

  def show
    @todo_lists = current_user.todo_lists
    @todos = @todo_list.todos.active.order(id: :asc)
    @logs = EventLog.where(log_tag: @todo_list.log_tag).order(id: :desc).limit(10)
  end

  def edit
    @todo_listship = @todo_list.todo_listships.new
    @users = @todo_list.users
                       .includes(:todo_listships)
                       .where(todo_listships: { todo_list_id: @todo_list.id })
  end

  def update
    @todo_list.update!(todo_list_params)

    @log = EventLogger.log(
      resource: @todo_list,
      user: current_user,
      action: :update,
      changes: @todo_list.previous_changes.except(:updated_at)
    )
    ActionCable.server.broadcast(@todo_list.log_tag, action: 'update_todo_list')

    flash[:notice] = 'Name is updated!'
    redirect_to edit_todo_list_path(@todo_list)
  end

  def destroy
    @todo_list.destroy!
    @log = EventLogger.log(
      resource: @todo_list,
      user: current_user,
      action: :destroy
    )
    ActionCable.server.broadcast(@todo_list.log_tag, action: 'destroy_todo_list')

    flash[:notice] = "List #{@todo_list.name} is deleted!"
    redirect_to todo_lists_path
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end

  def set_todo_list
    @todo_list = current_user.todo_lists.find(params[:id])
  end

  def check_update_permission
    current_user_role = current_user.role_of(@todo_list)
    unless current_user_role.owner? || current_user_role.admin?
      flash[:alert] = 'You cannot update this todo list.'
      return redirect_to edit_todo_list_path(@todo_list)
    end
  end

  def check_destroy_permission
    unless current_user.role_of(@todo_list).owner?
      flash[:alert] = 'You cannot delete this todo list.'
      redirect_to edit_todo_list_path(@todo_list)
    end
  end
end
