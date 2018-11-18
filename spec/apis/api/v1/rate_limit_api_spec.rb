require 'rails_helper'

describe API::V1::RateLimitAPI, type: :request do
  let(:user) { create(:user1) }

  describe 'GET /api/v1/tokens' do
    let!(:token) { create(:token, user: user, note: 'note', scopes: ['read:log']) }
    let(:endpoint) { '/api/v1/rate_limit' }

    before do
      APIRateCounter.redis.flushdb
      APIRateCounter.counters.clear
    end

    context 'when user authenticate with session' do
      subject { get endpoint }

      before { sign_in user }

      it 'returns 401' do
        subject
        expect(response).to have_http_status 401
      end
    end

    context 'when user authenticate with token' do
      let(:token) { create(:token, user: user) }
      let(:payload) { { id: token.id } }
      let(:access_token) { JSONWebToken.encode(payload) }
      let(:headers) { { 'Authorization' => "token #{access_token}" } }

      subject { get endpoint, headers: headers }

      it 'returns success and API rate usage' do
        Timecop.freeze do
          subject
          expect(response).to have_http_status :success
          counters = APIRateCounter.counters.counters.values
          expect(response.body).to eq Entity::V1::APIRateLimit.represent(counters).to_json
        end
      end
    end
  end
end
