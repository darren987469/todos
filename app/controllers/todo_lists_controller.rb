class TodoListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @todo_lists = TodoList.all
  end

  def show
    @todo_list = TodoList.find(params[:id])
  end
end
