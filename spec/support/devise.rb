require 'devise'
require 'support/controller_macros'
require 'support/request_spec_helper'

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.extend ControllerMacros, type: :controller
  config.include RequestSpecHelper, type: :request
end
