# frozen_string_literal: true

require 'rails_helper'

describe TodoListsController, type: :request do
  let(:user) { create(:user1) }
  let(:member) { create(:user2) }
  let(:todo_list) { @todo_list }

  def create_todo_list(role: :owner)
    todo_list = create(:todo_list)
    create(:todo_listship, user: user, todo_list: todo_list, role: role)
    create(:log, resourceable: todo_list, user: user, action: :create)
    todo_list
  end

  before do
    sign_in user
    @todo_list = create_todo_list
  end

  describe 'POST /todo_lists/:todo_list_id/todo_listships' do
    subject { post "/todo_lists/#{todo_list.id}/todo_listships", params: { email: member.email, role: 'user' } }

    context 'when current_user role is not owner or admin' do
      before { user.todo_listships.first.update(role: :user) }

      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }

      it 'renders correctly after redirect' do
        subject
        follow_redirect!
        expect(response.body).to include 'You cannot add member'
      end
    end

    context 'when cannot find member by email' do
      let(:params) { { email: 'no_exist_email' } }

      subject { post "/todo_lists/#{todo_list.id}/todo_listships", params: params }
      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }

      it 'renders correctly after redirect' do
        subject
        follow_redirect!
        expect(response.body).to include 'No such user.'
      end
    end

    context 'when success' do
      it 'create user role for member' do
        expect { subject }.to change { TodoListship.count }.by(1)

        todo_listship = TodoListship.last
        expect(todo_listship.user).to eq member
        expect(todo_listship.role).to eq 'user'
      end

      it 'calls TodoListChannel::TodoListshipOperations' do
        expect_any_instance_of(TodoListChannel::TodoListshipOperations).to receive(:create)
        subject
      end

      it 'broadcasts changes' do
        expect(ActionCable.server).to receive(:broadcast)
        subject
      end

      it { expect { subject }.to change { EventLog.count }.by(1) }
      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
    end
  end

  describe 'PATCH /todo_lists/:todo_list_id/todo_listships' do
    let!(:member_todo_listship) do
      create(:todo_listship, user: member, todo_list: todo_list, role: :user)
    end
    let(:endpoint) { "/todo_lists/#{todo_list.id}/todo_listships/#{member_todo_listship.id}" }
    let(:params) { { role: 'admin' } }

    subject { patch endpoint, params: params }

    it 'call TodoListChannel::TodoListshipOperations' do
      expect_any_instance_of(TodoListChannel::TodoListshipOperations).to receive(:update)
      subject
    end

    context 'NotAuthorizedError' do
      let(:operation_class) { TodoListChannel::TodoListshipOperations }
      before { allow_any_instance_of(operation_class).to receive(:update) { raise Pundit::NotAuthorizedError } }

      it { expect(subject).to redirect_to edit_todo_list_todo_listship_path(todo_list, member_todo_listship) }

      it 'renders correctly after redirect' do
        subject
        follow_redirect!
        expect(response.body).to include 'You cannot perform this action.'
      end

      it 'won\'t update todo_listship' do
        subject
        expect(member_todo_listship.reload.role).to eq 'user'
      end
    end

    it 'updates todo_listship' do
      expect { subject }.to change { member_todo_listship.reload.role }.from('user').to('admin')
    end

    it { expect { subject }.to change { EventLog.count }.by(1) }
    it { expect(subject).to redirect_to edit_todo_list_todo_listship_path(todo_list, member_todo_listship) }
  end

  describe 'DELETE /todo_lists/:todo_list_id/todo_listships/:id' do
    let!(:member_todo_listship) do
      create(:todo_listship, user: member, todo_list: todo_list, role: :user)
    end

    context 'when current_user delete self from todo list' do
      subject do
        user_todo_listship = user.todo_listships.first
        delete "/todo_lists/#{todo_list.id}/todo_listships/#{user_todo_listship.id}"
      end

      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }

      it 'renders correctly after redirect' do
        subject
        follow_redirect!
        expect(response.body).to include 'You cannot perform this action.'
      end

      it 'won\'t destroy todo_listship' do
        subject
        expect(member_todo_listship.reload).to be_present
      end
    end

    subject { delete "/todo_lists/#{todo_list.id}/todo_listships/#{member_todo_listship.id}" }

    context 'when current_user has no permission(member role >= current_user)' do
      before { member_todo_listship.update(role: :owner) }

      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }

      it 'renders correctly after redirect' do
        subject
        follow_redirect!
        expect(response.body).to include 'You cannot perform this action.'
      end

      it 'won\'t destroy todo_listship' do
        subject
        expect(member_todo_listship.reload).to be_present
      end
    end

    context 'when success' do
      it 'calls TodoListChannel::TodoListshipOperations' do
        expect_any_instance_of(TodoListChannel::TodoListshipOperations).to receive(:destroy)
        subject
      end

      it 'broadcasts changes' do
        expect(ActionCable.server).to receive(:broadcast)
        subject
      end

      it { expect { subject }.to change { TodoListship.count }.by(-1) }
      it { expect { subject }.to change { EventLog.count }.by(1) }
      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
    end
  end
end
