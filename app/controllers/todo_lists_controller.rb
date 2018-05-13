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
end
