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
    subject { post "/todo_lists/#{todo_list.id}/todo_listships", params: { email: member.email } }

    context 'when current_user role is not owner or admin' do
      before { user.todo_listships.first.update(role: :user) }

      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
      it { subject; follow_redirect!; expect(response.body) .to include 'You cannot add member'  }
    end

    context 'when cannot find member by email' do
      subject { post "/todo_lists/#{todo_list.id}/todo_listships", params: { email: 'no_exist_email' } }
      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
      it { subject; follow_redirect!; expect(response.body).to include 'No user.' }
    end

    context 'when success' do
      it 'create user role for member' do
        expect { subject }.to change { TodoListship.count }.by(1)

        todo_listship = TodoListship.last
        expect(todo_listship.user).to eq member
        expect(todo_listship.role).to eq 'user'
      end

      it 'create log' do
        expect(::EventLogger).to receive(:log).with(
          resource: todo_list,
          user: user,
          action: 'create',
          description: "#{user.name} add a member #{member.name} to todo list.",
          tag: "todo_list_#{todo_list.id}"
        )
        subject
      end
      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
    end
  end

  describe 'DELETE /todo_lists/:todo_list_id/todo_listships/:id' do
    let!(:member_todo_listship) { create(:todo_listship, user: member, todo_list: todo_list, role: :user) }

    context 'when current_user delete self from todo list' do
      subject do
        user_todo_listship = user.todo_listships.first
        delete "/todo_lists/#{todo_list.id}/todo_listships/#{user_todo_listship.id}"
      end

      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
      it { subject; follow_redirect!; expect(response.body).to include 'You cannot delete yourself.' }
    end

    subject { delete "/todo_lists/#{todo_list.id}/todo_listships/#{member_todo_listship.id}" }

    context 'when current_user has no permission(member role is qual or greater than current_user)' do
      before { member_todo_listship.update(role: :owner) }

      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
      it { subject; follow_redirect!; expect(response.body).to include 'You cannot delete this member.' }
    end

    context 'when success' do
      it { expect { subject }.to change { TodoListship.count }.by(-1) }
      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
    end
  end
end
