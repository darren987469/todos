require 'rails_helper'

describe Entity::V1::EncodedToken do
  let(:user) { create(:user1) }
  let(:token) { create(:token, user: user, note: 'note', scopes: ['read:log']) }

  subject { described_class.new(token).as_json }

  it { expect(subject[:encoded_token]).to eq JSONWebToken.encode(token.payload) }
end
