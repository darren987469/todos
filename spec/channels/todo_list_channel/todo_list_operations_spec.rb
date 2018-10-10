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
end