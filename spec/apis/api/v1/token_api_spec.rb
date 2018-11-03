require 'rails_helper'

describe API::V1::TokenAPI, type: :request do
  let(:user) { create(:user1) }

  describe 'POST /api/v1/tokens' do
    let(:endpoint) { '/api/v1/tokens' }
    let(:params) do
      {
        note: 'Token description',
        scopes: ['read:log']
      }
    end

    subject { post endpoint, params: params }

    before { sign_in user }

    context 'invalid params' do
      after { expect(response).to have_http_status :bad_request }

      it { post endpoint, params: { note: '' } }
      it { post endpoint, params: { note: 'note', scopes: ['invalid scope'] } }
    end

    context 'duplicate scopes' do
      it 'removes duplicate one' do
        params[:scopes] = params[:scopes] * 2
        subject

        expect(response).to have_http_status :success
        expect(JSON.parse(response.body)['scopes']).to eq params[:scopes].uniq
      end
    end

    it 'returns success' do
      subject
      expect(response).to have_http_status :success
    end

    it 'creates token and returns it' do
      expect { subject }.to change { Token.count }.by(1)

      expected_body = Entity::V1::EncodedToken.represent(Token.last).to_json
      expect(response.body).to eq expected_body
    end
  end
end
