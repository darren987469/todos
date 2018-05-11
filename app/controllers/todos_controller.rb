class TodosController < ApplicationController
  before_action :authenticate_user!

  def create
    @todo = Todo.new(todo_params.merge(todo_list_id: params[:todo_list_id]))
    if @todo.save
      success_response
    else
      fail_response
    end
  end

  def update
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params[:id])
    if @todo.update(todo_params)
      success_response
    else
      fail_response
    end
  end

  def destroy
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params[:id])
    if @todo.destroy
      success_response
    else
      fail_response
    end
  end

  private
    def todo_params
      params.require(:todo).permit(:description, :complete)
    end

    def success_response
      ActionCable.server.broadcast "todo_list_#{params[:todo_list_id]}", todo: @todo
      render json: @todo
    end

    def fail_response
      render json: { errors: @todo.errors.messages }, status: :bad_request
    end
end
