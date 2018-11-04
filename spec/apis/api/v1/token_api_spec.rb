require 'rails_helper'

describe API::V1::TokenAPI, type: :request do
  let(:user) { create(:user1) }

  describe 'GET /api/v1/tokens' do
    let!(:token) { create(:token, user: user, note: 'note', scopes: ['read:log']) }
    let(:endpoint) { '/api/v1/tokens' }

    subject { get endpoint }

    before { sign_in user }

    it 'returns success and tokens' do
      subject
      expect(response).to have_http_status :success
      expected_body = Entity::V1::Token.represent([token]).to_json
      expect(response.body).to eq expected_body
    end
  end

  describe 'GET /api/v1/tokens' do
    let!(:token) { create(:token, user: user, note: 'note', scopes: ['read:log']) }
    let(:endpoint) { "/api/v1/tokens/#{token.id}" }

    subject { get endpoint }

    before { sign_in user }

    it 'returns success and tokens' do
      subject
      expect(response).to have_http_status :success
      expected_body = Entity::V1::Token.represent(token).to_json
      expect(response.body).to eq expected_body
    end
  end

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

  describe 'PATCH /api/v1/tokens/:token_id' do
    let!(:token) { create(:token, user: user, note: 'note', scopes: ['read:log']) }
    let(:endpoint) { "/api/v1/tokens/#{token.id}" }
    let(:params) do
      {
        note: 'Token description',
        scopes: ['write:log']
      }
    end

    subject { patch endpoint, params: params }

    before { sign_in user }

    context 'invalid params' do
      after { expect(response).to have_http_status :bad_request }

      it { patch endpoint, params: { note: '' } }
      it { patch endpoint, params: { note: 'note', scopes: ['invalid scope'] } }
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
      expected_body = Entity::V1::Token.represent(token.reload).to_json
      expect(response.body).to eq expected_body
    end

    it 'update token' do
      subject
      expect(token.reload).to have_attributes(
        note: params[:note],
        scopes: params[:scopes]
      )
    end
  end

  describe 'DELETE /api/v1/tokens/:token_id' do
    let!(:token) { create(:token, user: user, note: 'note', scopes: ['read:log']) }
    let(:endpoint) { "/api/v1/tokens/#{token.id}" }

    subject { delete endpoint }

    before { sign_in user }

    it 'deletes token and returns success' do
      expect { subject }.to change { Token.count }.by(-1)

      expect(response).to have_http_status :success
      expected_body = Entity::V1::Token.represent(token).to_json
      expect(response.body).to eq expected_body
    end
  end
end
