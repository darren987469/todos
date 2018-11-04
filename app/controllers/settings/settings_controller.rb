module Settings
  class SettingsController < ApplicationController
    def index
      @tokens = current_user.tokens
    end
  end
end
