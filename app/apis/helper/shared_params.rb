module Helper
  module SharedParams
    extend Grape::API::Helpers

    params :period do
      optional :start_date, type: Date, default: Date.today
      optional :end_date, type: Date, default: Date.today
    end

    params :pagination do |_options|
      optional :per, type: Integer, default: 10, values: 1..100, desc: 'Number of results to return.'
      optional :per_page, type: Integer, default: 1, desc: 'Page of results.'
    end
  end
end
