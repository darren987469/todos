require 'rails_helper'

describe API::V1::EventLogAPI, type: :request do
  describe 'GET /api/v1/todo_list/:todo_list_id/logs' do
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
        end_date: Date.today
      }
    end

    shared_examples 'GET logs API' do
      context 'invalid date range' do
        it 'returns bad_request' do
          params[:start_date] = Date.today
          params[:end_date] = Date.yesterday

          subject
          expect(response).to have_http_status :bad_request
        end
      end

      context 'no event log in query period' do
        it 'returns no_content' do
          subject
          expect(response).to have_http_status :no_content
        end
      end

      context 'event log exists' do
        let!(:event_log) do
          create(
            :log,
            resourceable: todo_list,
            user: user,
            log_tag: todo_list.log_tag,
            action: 'create',
            description: 'description'
          )
        end

        it 'returns success and event logs' do
          subject
          expect(response).to have_http_status :success
          expect(response.body).to eq Entity::V1::EventLog.represent([event_log]).to_json
        end
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
    end

    context 'authenticate with token' do
      let(:token) { create(:token, user: user) }
      let(:payload) { { id: token.id } }
      let(:access_token) { JSONWebToken.encode(payload) }
      let(:headers) { { 'Authorization' => "token #{access_token}" } }

      subject { get endpoint, params: params, headers: headers }

      it_behaves_like 'GET logs API'
    end
  end
end
