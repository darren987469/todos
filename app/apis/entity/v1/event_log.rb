module Entity
  module V1
    class EventLog < Grape::Entity
      expose :todo_list_id, documentation: { type: Integer }
      expose :resource, documentation: {
        type: String,
        desc: 'Resource which processed by the user. Resource maybe TodoList, TodoListship, Todo.'
      }
      expose :resource_id, documentation: { type: Integer }
      expose :user_id, documentation: { type: Integer }
      expose :action, documentation: { type: String, desc: 'Action at the resource.' }
      expose :description, documentation: { type: String, desc: 'Description of user action on resource.' }

      def todo_list_id
        # 'todo_list_123' => 123
        object.log_tag.scan(/\d+/).first.to_i
      end

      def resource
        object.resourceable_type
      end

      def resource_id
        object.resourceable_id
      end
    end
  end
end
