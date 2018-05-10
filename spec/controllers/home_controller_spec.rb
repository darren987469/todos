require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  it 'response 200' do
    get :index
    expect(response.status).to eq 200
  end
end
