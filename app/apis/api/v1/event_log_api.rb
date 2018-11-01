module API
  module V1
    class EventLogAPI < Grape::API
      content_type :json, 'application/json'
      content_type :csv,  'application/csv'

      desc(
        'Get logs of TodoList',
        tags: ['logs'],
        success: Entity::V1::EventLog,
        is_array: true
      )
      params do
        requires :start_date, type: Date, default: Date.today
        requires :end_date, type: Date, default: Date.today
      end
      get 'todo_list/:todo_lis_id/logs' do
        start_date = params[:start_date].beginning_of_day
        end_date = params[:end_date].end_of_day
        error!('Invalid date range.', 400) unless end_date > start_date

        todo_list = current_user.todo_lists.find(params[:todo_lis_id])
        event_logs = EventLog.where(log_tag: todo_list.log_tag)

        present event_logs, with: Entity::V1::EventLog
      end
    end
  end
end
