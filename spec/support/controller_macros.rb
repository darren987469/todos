module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryBot.create(:user1)
      sign_in @user
    end
  end
end
