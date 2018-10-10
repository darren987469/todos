# frozen_string_literal: true

class TodoListChannel
  class BaseOperations
    attr_reader :stream_token, :current_user, :params, :channel_action, :action_name

    def initialize(stream_token, current_user, params)
      @stream_token = stream_token
      @current_user = current_user
      @params = params
      @channel_action = params[:method] # pattern: create_resource, e.g. create_todo
      @action_name = @channel_action.split('_').first
    end

    def dispatch
      send(action_name)
    end
  end
end
