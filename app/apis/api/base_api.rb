module API
  class BaseAPI < Grape::API
    default_format :json
    formatter :csv, Formatter::V1::CSV

    helpers Helper::Devise

    rescue_from Grape::Exceptions::ValidationErrors do |error|
      error!(error.message, 400)
    end

    rescue_from Pundit::NotAuthorizedError do |_error|
      error!('Forbidden.', 403)
    end

    rescue_from ActiveRecord::RecordNotFound do |_error|
      error!('Not Found.', 404)
    end

    if Rails.env.production? || Rails.env.staging?
      rescue_from :all do |_error|
        error!('Internal Server Error.', 500)
      end
    end

    mount API::V1::BaseAPI => '/v1'

    add_swagger_documentation(
      mount_path: '/swagger_doc',
      info: {
        title: 'API',
        description: 'API documentation'
      },
      produces: [
        'application/json',
        'application/csv'
      ],
      models: [
        Entity::V1::EventLog
      ]
    )
  end
end
