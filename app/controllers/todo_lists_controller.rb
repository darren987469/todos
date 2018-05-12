class TodoListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @todo_lists = TodoList.all
  end

  def show
    @todo_list = TodoList.find(params[:id])
    @todos = @todo_list.todos.order(id: :asc)
    @logs = EventLog.where(resourceable: @todos).order(id: :desc).limit(10).as_json(log_as_json)
  end

  private
    def log_as_json
      {
        only: [:id, :description, :created_at]
      }
    end
end
