# frozen_string_literal: true

require 'rails_helper'

describe TodoListChannel::TodoListshipOperations do
  let(:user) { create(:user1) }
  let(:member) { create(:user2) }
  let(:todo_list) { create(:todo_list) }
  let!(:todo_listship) { create(:todo_listship, user: user, todo_list: todo_list, role: :owner) }

  describe '#destroy' do
    let!(:member_todo_listship) do
      create(:todo_listship, user: member, todo_list: todo_list, role: :user)
    end
    let(:params) do
      ActionController::Parameters.new(
        todo_list_id: todo_list.id,
        id: member_todo_listship.id
      )
    end

    subject { described_class.new(user, params, todo_list).destroy }

    before { allow_any_instance_of(TodoListshipPolicy).to receive(:delete?) { true } }

    it 'destroy todo_listship' do
      expect { subject }.to change { TodoListship.count }.by(-1)
    end

    it 'creates log' do
      expect { subject }.to change { EventLog.count }.by(1)
      expect(EventLog.last).to have_attributes(
        resourceable_type: 'TodoListship',
        resourceable_id: member_todo_listship.id,
        user: user,
        action: 'destroy',
        log_tag: todo_list.log_tag,
        description: %(#{user.name} delete member #{member.name} from todo list.)
      )
    end

    it 'broadcasts todo_list and log' do
      log_double = double('log')
      allow(EventLogger).to receive(:log) { log_double }

      expect(ActionCable.server).to receive(:broadcast).with(
        todo_list.log_tag,
        action: 'delete_member',
        member: member,
        log: log_double
      )
      subject
    end
  end
end
