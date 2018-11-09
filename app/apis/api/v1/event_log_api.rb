module API
  module V1
    class EventLogAPI < Grape::API
      helpers Helper::SharedParams

      before { authenticate_user! }

      desc(
        'Get logs of TodoList',
        tags: ['logs'],
        success: Entity::V1::PaginatedEventLog,
        is_array: true
      )
      params do
        use :period, :pagination
      end
      get 'todo_list/:todo_lis_id/logs' do
        start_date = params[:start_date].beginning_of_day
        end_date = params[:end_date].end_of_day
        error!('Invalid date range.', 400) unless end_date > start_date

        todo_list = current_user.todo_lists.find(params[:todo_lis_id])
        event_logs = EventLog.where(log_tag: todo_list.log_tag)

        paginate event_logs, with: Entity::V1::PaginatedEventLog
      end
    end
  end
end
