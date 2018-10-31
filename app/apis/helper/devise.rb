module Helper
  module Devise
    def warden
      env['warden']
    end

    def sign_in(user)
      warden.set_user(user)
    end

    def current_user
      warden.user
    end
  end
end
