class TodoListsController < ApplicationController
  def show
    @todo_list = TodoList.includes(:todos).find(1)
  end
end
