class TodosController < ApplicationController
  before_action :authenticate_user!

  def create
    @todo = Todo.new(todo_params.merge(todo_list_id: params[:todo_list_id]))
    if @todo.save
      ActionCable.server.broadcast 'todo_list', todo: @todo
      render json: @todo
    else
      render json: { errors: @todo.errors.messages }, status: :bad_request
    end
  end

  def update
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params[:id])
    if @todo.update(todo_params)
      ActionCable.server.broadcast 'todo_list', todo: @todo
      render json: @todo
    else
      render json: { errors: @todo.errors.messages }, status: :bad_request
    end
  end

  def destroy
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params[:id])
    if @todo.destroy
      ActionCable.server.broadcast 'todo_list', todo: @todo
      render json: @todo
    else
      render json: { errors: @todo.errors.messages }, status: :bad_request
    end
  end

  private
    def todo_params
      params.require(:todo).permit(:description, :complete)
    end
end
