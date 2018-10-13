# frozen_string_literal: true

require 'rails_helper'

describe TodoListChannel::TodoListOperations do
  let(:stream_token) { 'token' }
  let(:user) { create(:user1) }

  describe '#create' do
    let(:params) do
      ActionController::Parameters.new(
        name: 'new todo list',
        method: 'create_todo_list'
      )
    end

    subject { described_class.new(stream_token, user, params).create }

    it 'creates todo_list' do
      expect { subject }.to change { TodoList.count }.by(1)
      expect(TodoList.last).to have_attributes(
        name: 'new todo list'
      )
    end

    it 'creates todo_listship' do
      expect { subject }.to change { TodoListship.count }.by(1)
      expect(TodoListship.last).to have_attributes(
        user: user,
        role: 'owner'
      )
    end

    it 'creates log' do
      expect { subject }.to change { EventLog.count }.by(1)

      todo_list = TodoList.last
      expect(EventLog.last).to have_attributes(
        resourceable: todo_list,
        user: user,
        action: 'create',
        log_tag: todo_list.log_tag,
        description: %(#{user.name} create a todo_list)
      )
    end

    it 'broadcasts todo_list and log' do
      todo_list_double = double('todo_list', id: 1, log_tag: 'log_tag', errors: [])
      log_double = double('log')
      allow(TodoList).to receive(:create!) { todo_list_double }
      allow(todo_list_double).to receive_message_chain(:todo_listships, :create!)
      allow(EventLogger).to receive(:log) { log_double }

      expect(ActionCable.server).to receive(:broadcast).with(
        stream_token,
        action: 'create_todo_list',
        todo_list: todo_list_double,
        log: log_double,
        errors: nil
      )
      subject
    end
  end

  describe '#update(todo_list)' do
    let(:todo_list) { create(:todo_list, name: 'original name') }
    let!(:todo_listship) { create(:todo_listship, user: user, todo_list: todo_list, role: :owner) }
    let(:params) do
      ActionController::Parameters.new(
        todo_list: { name: 'updated name' },
        method: 'update_todo_list'
      )
    end

    subject { described_class.new(stream_token, user, params).update(todo_list) }

    context 'when user is not authorized to update todo_list' do
      before { todo_listship.update(role: :user) }

      it 'raise error and won\'t update todo_list' do
        expect(todo_list.name).to eq 'original name'
        expect { subject }.to raise_error Pundit::NotAuthorizedError
        expect(todo_list.name).to eq 'original name'
      end
    end

    it 'updates todo_list' do
      expect(todo_list.name).to eq 'original name'
      subject
      expect(todo_list.reload.name).to eq 'updated name'
    end

    it 'creates log' do
      expect { subject }.to change { EventLog.count }.by(1)

      todo_list = TodoList.last
      expect(EventLog.last).to have_attributes(
        resourceable: todo_list,
        user: user,
        action: 'update',
        log_tag: todo_list.log_tag,
        description: %(#{user.name} update a todo_list)
      )
    end

    it 'broadcasts todo_list and log' do
      log_double = double('log')
      allow(EventLogger).to receive(:log) { log_double }

      expect(ActionCable.server).to receive(:broadcast).with(
        stream_token,
        action: 'update_todo_list',
        todo_list: todo_list.reload,
        log: log_double,
        errors: nil
      )
      subject
    end
  end

  describe '#destroy(todo_list)' do
    let(:todo_list) { create(:todo_list) }
    let!(:todo_listship) { create(:todo_listship, user: user, todo_list: todo_list, role: :owner) }
    let(:params) { ActionController::Parameters.new(method: 'destroy_todo_list') }

    subject { described_class.new(stream_token, user, params).destroy(todo_list) }

    context 'when user is not authorized to destroy todo_list' do
      before { todo_listship.update(role: :user) }

      it 'raise error and won\'t destroy todo_list' do
        expect { subject }.to raise_error Pundit::NotAuthorizedError
        expect(todo_list.reload).to be_present
      end
    end

    it 'destroy todo_list' do
      expect { subject }.to change { TodoList.count }.by(-1)
    end

    it 'creates log' do
      expect { subject }.to change { EventLog.count }.by(1)

      expect(EventLog.last).to have_attributes(
        resourceable_type: 'TodoList',
        resourceable_id: todo_list.id,
        user: user,
        action: 'destroy',
        log_tag: todo_list.log_tag,
        description: %(#{user.name} destroy a todo_list)
      )
    end

    it 'broadcasts todo_list and log' do
      log_double = double('log')
      allow(EventLogger).to receive(:log) { log_double }

      expect(ActionCable.server).to receive(:broadcast).with(
        stream_token,
        action: 'destroy_todo_list',
        todo_list: todo_list,
        log: log_double,
        errors: nil
      )
      subject
    end
  end
end
