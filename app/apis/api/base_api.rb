module API
  class BaseAPI < Grape::API
    format :json
    formatter :csv, Formatter::V1::CSV

    helpers Helper::Base, Helper::Devise
    helpers Helper::TokenAuthenticate, Helper::TokenAuthorize
    helpers Helper::Pagination, Helper::Throttle

    rescue_from Grape::Exceptions::ValidationErrors do |error|
      error!(error.message, 400)
    end

    rescue_from NotAuthenticatedError do |_error|
      error!('Unauthorized.', 401)
    end

    rescue_from Pundit::NotAuthorizedError do |_error|
      error!('Forbidden.', 403)
    end

    rescue_from ActiveRecord::RecordNotFound do |_error|
      error!('Not Found.', 404)
    end

    rescue_from RateLimitExceededError do |_error|
      error!('API rate limit exceeded.', 429)
    end

    if Rails.env.production? || Rails.env.staging?
      rescue_from :all do |_error|
        error!('Internal Server Error.', 500)
      end
    end

    mount API::V1::BaseAPI => '/v1'

    add_swagger_documentation(
      tags: [
        { name: 'Internal API', description: 'API for internal use. Authenticate with session.' },
        { name: 'Public API', description: 'Authenticate with token.' }
      ],
      hide_documentation_path: true,
      api_documentation: { desc: 'ttt desc' },
      mount_path: '/swagger_doc',
      info: {
        title: 'API',
        description: 'Authenticate with token guide: https://github.com/darren987469/todos/blob/master/doc/how_to_authenticate_with_token.md.'
      },
      produces: ['application/json'],
      models: [
        Entity::V1::EventLog
      ]
    )
  end
end
