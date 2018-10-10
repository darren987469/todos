# frozen_string_literal: true

class TodoListChannel < ApplicationCable::Channel
  attr_reader :params

  class UnknownAction < StandardError; end
  class NotAuthorizedError < StandardError; end

  def subscribed
    todo_list = TodoList.find(params[:id])
    @stream_token = todo_list.log_tag
    stream_from @stream_token
  end

  def request(data)
    @params = ActionController::Parameters.new data

    case params[:method]
    when 'create_todo', 'update_todo', 'destroy_todo'
      TodoOperations.new(@stream_token, current_user, @params).dispatch
    when 'create_todo_list'
      TodoListOperations.new(@stream_token, current_user, @params).dispatch
    else
      raise UnknownAction
    end
  rescue ActiveRecord::RecordNotFound
    broadcast_errors(['RecordNotFound'])
  rescue NotAuthorizedError
    broadcast_errors(['Forbidden'])
  rescue StandardError => _e
    broadcast_errors(['500 Error'])
    raise if Rails.env.development?
  end

  private

  def broadcast_errors(errors)
    ActionCable.server.broadcast("todo_list_#{params[:todo_list_id]}", errors: errors)
  end
end
