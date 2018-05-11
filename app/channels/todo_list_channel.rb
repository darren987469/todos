class TodoListChannel < ApplicationCable::Channel
  attr_reader :params

  def subscribed
    stream_from "todo_list_#{params[:id]}"
  end

  def post(data)
    @params = ActionController::Parameters.new data
    @todo = Todo.new(todo_params.merge(todo_list_id: params[:todo_list_id]))
    @todo.save
    ActionCable.server.broadcast("todo_list_#{params[:todo_list_id]}",
      method: 'post',
      todo: @todo,
      errors: @todo.errors.messages.presence
    )
  end

  def patch(data)
    @params = ActionController::Parameters.new data
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
    @todo.update(todo_params)
    ActionCable.server.broadcast("todo_list_#{params[:todo_list_id]}",
      method: 'patch',
      todo: @todo,
      errors: @todo.errors.messages.presence
    )
  end

  def delete(data)
    @params = ActionController::Parameters.new data
    @todo = Todo.find_by(todo_list_id: params[:todo_list_id], id: params.dig(:todo, :id))
    @todo.destroy
    ActionCable.server.broadcast("todo_list_#{params[:todo_list_id]}",
      method: 'delete',
      todo: @todo,
      errors: @todo.errors.messages.presence
    )
  end

  private
    def todo_params
      params.require(:todo).permit(:description, :complete, :id)
    end
end
