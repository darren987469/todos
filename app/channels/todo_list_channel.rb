class TodoListChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'todo_list'
  end
end
