# frozen_string_literal: true

class TodoListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_list, only: %i[show edit update destroy]
  rescue_from Pundit::NotAuthorizedError do
    flash[:alert] = 'You cannot perform this action'
    redirect_to edit_todo_list_path(@todo_list)
  end

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
    @todo_listships = TodoListship.includes(:user)
                                  .where(todo_list_id: @todo_list.id)
  end

  def update
    authorize @todo_list, :update?

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
    authorize @todo_list, :delete?

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
end
