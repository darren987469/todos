require 'rails_helper'

describe Helper::TokenAuthorize do
  include Helper::TokenAuthorize

  let(:token) { create(:token, scopes: scopes) }

  def access_token
    token
  end

  describe '#authorize_with_token' do
    subject { authorize_with_token('read:resource') }

    context 'when scope is in token.scopes' do
      let(:scopes) { ['read:resource'] }

      it 'returns true' do
        expect(subject).to eq true
      end
    end

    context 'when scope is not in token.scopes' do
      let(:scopes) { [] }

      it 'raises error' do
        expect { subject }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end
end
