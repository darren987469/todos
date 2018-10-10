# frozen_string_literal: true

require 'rails_helper'

describe TodoListChannel::TodoOperations do
  let(:stream_token) { 'token' }
  let(:user) { create(:user1) }
  let(:todo_list) { create(:todo_list) }
  let!(:todo_listship) { create(:todo_listship, user: user, todo_list: todo_list, role: :owner) }

  describe '#create' do
    let(:params) do
      ActionController::Parameters.new(
        todo: { description: 'first todo' },
        todo_list_id: todo_list.id,
        method: 'create_todo'
      )
    end
    subject { described_class.new(stream_token, user, params).create }

    it 'creates todo' do
      expect { subject }.to change { Todo.count }.by(1)
      expect(Todo.last).to have_attributes(
        todo_list_id: todo_list.id,
        description: params[:todo][:description]
      )
    end

    it 'creates log' do
      expect { subject }.to change { EventLog.count }.by(1)

      todo = Todo.last
      expect(EventLog.last).to have_attributes(
        resourceable: todo,
        user: user,
        action: 'create',
        log_tag: todo_list.log_tag,
        description: %(#{user.name} create a todo)
      )
    end

    it 'broadcast todo and log' do
      todo_double = double('todo', todo_list_id: todo_list.id, errors: [])
      log_double = double('log')
      allow(Todo).to receive(:create) { todo_double }
      allow(EventLogger).to receive(:log) { log_double }

      expect(ActionCable.server).to receive(:broadcast).with(
        stream_token,
        action: 'create_todo',
        todo: todo_double,
        log: log_double,
        errors: nil
      )
      subject
    end
  end

  describe '#update' do
    let!(:todo) { create(:todo, todo_list: todo_list, description: 'before update') }
    let(:params) do
      ActionController::Parameters.new(
        todo: { id: todo.id, description: 'after update' },
        todo_list_id: todo_list.id,
        method: 'update_todo'
      )
    end
    subject { described_class.new(stream_token, user, params).update }

    it 'updates todo' do
      expect(todo.description).to eq 'before update'
      subject
      expect(todo.reload.description).to eq 'after update'
    end

    context 'when user completes todo' do
      before { params[:todo][:complete] = true }

      it 'updates todo.complete' do
        expect { subject }.to change { todo.reload.complete }.from(false).to(true)
      end
    end

    context 'when user archives todo' do
      it 'updates todo.archived_at' do
        Timecop.freeze(now = Time.current) do
          params[:todo][:archived_at] = now

          expect { subject }.to change { todo.reload.archived_at }.from(nil).to(now)
        end
      end
    end

    it 'creates log' do
      expect { subject }.to change { EventLog.count }.by(1)
      expect(EventLog.last).to have_attributes(
        resourceable: todo.reload,
        user: user,
        action: 'update',
        log_tag: todo_list.log_tag,
        description: %(#{user.name} update a todo),
        variation: { description: ['before update', 'after update'] }
      )
    end

    it 'broadcast todo and log' do
      log_double = double('log')
      allow(EventLogger).to receive(:log) { log_double }

      expect(ActionCable.server).to receive(:broadcast).with(
        stream_token,
        action: 'update_todo',
        todo: todo.reload,
        log: log_double,
        errors: nil
      )
      subject
    end
  end

  describe '#destroy' do
    let!(:todo) { create(:todo, todo_list: todo_list, description: 'before update') }
    let(:params) do
      ActionController::Parameters.new(
        todo: { id: todo.id },
        todo_list_id: todo_list.id,
        method: 'destroy_todo'
      )
    end
    subject { described_class.new(stream_token, user, params).destroy }

    it 'destroys todo' do
      expect { subject }.to change { Todo.count }.by(-1)
    end

    it 'creates log' do
      expect { subject }.to change { EventLog.count }.by(1)
      expect(EventLog.last).to have_attributes(
        resourceable_type: 'Todo',
        resourceable_id: todo.id,
        user: user,
        action: 'destroy',
        log_tag: todo_list.log_tag,
        description: %(#{user.name} destroy a todo)
      )
    end

    it 'broadcast todo and log' do
      log_double = double('log')
      allow(EventLogger).to receive(:log) { log_double }

      expect(ActionCable.server).to receive(:broadcast).with(
        stream_token,
        action: 'destroy_todo',
        todo: todo,
        log: log_double,
        errors: nil
      )
      subject
    end
  end
end
