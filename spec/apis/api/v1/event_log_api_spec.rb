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

    before { APIRateCounter.redis.flushdb }

    shared_examples 'GET logs API' do
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

      it_behaves_like 'GET logs API'

      context 'when API rate limit exceeded' do
        before do
          counter = APIRateCounter.add(api_name, 5000, 1.hour)
          counter.increment(5000)
        end

        it 'won\'t affect user authenticate with session' do
          subject
          expect(response).to have_http_status :success
        end
      end
    end

    context 'authenticate with token' do
      let(:token) { create(:token, user: user) }
      let(:payload) { { id: token.id } }
      let(:access_token) { JSONWebToken.encode(payload) }
      let(:headers) { { 'Authorization' => "token #{access_token}" } }

      subject { get endpoint, params: params, headers: headers }

      it_behaves_like 'GET logs API'

      context 'when API rate limit exceeded' do
        before do
          counter = APIRateCounter.add(api_name, 5000, 1.hour)
          counter.increment(5000)
        end

        it 'returns 429' do
          subject
          expect(response).to have_http_status 429
        end
      end
    end
  end
end
