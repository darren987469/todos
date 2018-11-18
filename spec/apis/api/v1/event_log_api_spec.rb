require 'rails_helper'

describe API::V1::EventLogAPI, type: :request do
  describe 'GET /api/v1/todo_list/:todo_list_id/logs' do
    let(:api_name) { 'v1:event_log_api' }
    let(:user) { create(:user1) }
    let(:todo_list) do
      create(:todo_list).tap do |todo_list|
        create(:todo_listship, user: user, todo_list: todo_list, role: :owner)
      end
    end
    let(:endpoint) { "/api/v1/todo_list/#{todo_list.id}/logs" }
    let(:params) do
      {
        start_date: Date.today,
        end_date: Date.today,
        page: 1,
        per_page: 1
      }
    end

    before do
      APIRateCounter.redis.flushdb
      APIRateCounter.clear
    end

    context 'unauthenticate' do
      subject { get endpoint, params: params }

      it 'returns 401' do
        subject
        expect(response).to have_http_status 401
      end
    end

    context 'authenticate with session' do
      subject { get endpoint, params: params }

      before { sign_in user }

      it 'returns 401' do
        subject
        expect(response).to have_http_status 401
      end
    end

    context 'authenticate with token' do
      let(:token) { create(:token, user: user) }
      let(:payload) { { id: token.id } }
      let(:access_token) { JSONWebToken.encode(payload) }
      let(:headers) { { 'Authorization' => "token #{access_token}" } }

      subject { get endpoint, params: params, headers: headers }

      context 'invalid date range' do
        it 'returns bad_request' do
          params[:start_date] = Date.today
          params[:end_date] = Date.yesterday

          subject
          expect(response).to have_http_status :bad_request
        end
      end

      before { create(:log, resourceable: todo_list, user: user, log_tag: todo_list.log_tag) }

      it 'returns success and paginated event_logs' do
        subject
        expect(response).to have_http_status :success

        collection = EventLog.where(log_tag: todo_list.log_tag).page(params[:page]).per(params[:per_page])
        links = PaginationService.new(collection).links(request)
        paginated_event_logs = OpenStruct.new(
          collection: collection,
          links: OpenStruct.new(links)
        )
        expected = Entity::V1::PaginatedEventLog.represent(paginated_event_logs).to_json
        expect(response.body).to eq expected
      end

      context 'when API rate limit exceeded' do
        let(:discriminator) { token.id }

        before do
          counter_options = { api_name: api_name, limit: 5000, period: 1.hour, discriminator: discriminator }
          counter = APIRateCounter.get_or_add(counter_options)
          counter.increment(5000)
        end

        it 'returns 429' do
          subject
          expect(response).to have_http_status 429
        end

        context 'discriminator not the same as token.id' do
          let(:discriminator) { -1 }

          it 'returns success' do
            subject
            expect(response).to have_http_status :success
          end
        end
      end
    end
  end
end
