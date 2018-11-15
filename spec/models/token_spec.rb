require 'rails_helper'

describe Token, type: :model do
  let(:token) { create(:token) }

  describe '#encoded_token' do
    it { expect(token.encoded_token).to eq JSONWebToken.encode(token.payload) }
  end
end
