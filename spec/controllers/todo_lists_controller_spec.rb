# frozen_string_literal: true

require 'rails_helper'

describe TodoListsController, type: :request do
  let(:user) { create(:user1) }

  def create_todo_list(role: :owner)
    todo_list = create(:todo_list)
    create(:todo_listship, user: user, todo_list: todo_list, role: role)
    create(:log, resourceable: todo_list, user: user, action: :create)
    todo_list
  end

  before { sign_in user }

  describe 'GET /todo_lists' do
    subject { get '/todo_lists' }

    context 'when user has no todo list' do
      it { expect { subject }.to change { TodoList.count }.from(0).to(1) }
      it { expect { subject }.to change { TodoListship.count }.from(0).to(1) }
      it { expect(subject).to redirect_to todo_list_path(TodoList.first) }
    end

    context 'user has todo list' do
      it 'redirect to first list' do
        2.times { create_todo_list }
        expect(TodoList.count).to eq 2

        expect { subject }.not_to change { TodoList.count }
        expect(subject).to redirect_to todo_list_path(TodoList.first)
      end
    end
  end

  describe 'GET /todo_list/:id' do
    subject { get "/todo_lists/#{@todo_list.id}" }

    context 'when todo list not belongs to user' do
      before { @todo_list = create(:todo_list) }
      it { expect { subject }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'when todo list belongs to user' do
      before { @todo_list = create_todo_list }

      it 'render show' do
        expect(subject).to render_template :show
        todo_lists = user.todo_lists
        expect(assigns(:todo_lists)).to eq todo_lists
        expect(assigns(:todos)).to eq todo_lists.first.todos.active.order(id: :asc)
        expected_logs = EventLog.where(log_tag: todo_lists.first.log_tag).order(id: :desc).limit(10)
        expect(assigns(:logs)).to eq expected_logs
      end
    end
  end

  describe 'GET /todo_lists/:id/edit' do
    subject { get "/todo_lists/#{@todo_list.id}/edit" }
    before { @todo_list = create_todo_list(role: :user) }

    it { expect(subject).to render_template :edit }
  end

  describe 'PATCH /todo_lists/:id' do
    let(:todo_list) { @todo_list }
    let(:endpoint) { "/todo_lists/#{@todo_list.id}" }
    subject { patch endpoint, params: { todo_list: { name: 'updated_name' } } }

    context 'when user are not owner or admin of todo list' do
      before { @todo_list = create_todo_list(role: :user) }
      it { expect(subject).to redirect_to edit_todo_list_path(@todo_list) }
    end

    context 'when user has permission(owner or admin) to update' do
      before { @todo_list = create_todo_list(role: :owner) }

      it 'update todo_list name' do
        expect(todo_list.name).not_to eq 'updated_name'
        subject
        expect(todo_list.reload.name).to eq 'updated_name'
      end

      it { expect { subject }.to change { EventLog.count }.by(1) }
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          todo_list.log_tag,
          action: 'update_todo_list'
        )
        subject
      end
      it { expect(subject).to redirect_to edit_todo_list_path(todo_list) }
      it do
        subject
        follow_redirect!
        expect(response.body).to include 'Name is updated!'
      end
    end
  end

  describe 'DELETE /todo_lists/:id' do
    let(:todo_list) { @todo_list }
    subject { delete "/todo_lists/#{@todo_list.id}" }

    context 'when user are not owner or admin of todo list' do
      before { @todo_list = create_todo_list(role: :user) }
      it { expect(subject).to redirect_to edit_todo_list_path(@todo_list) }
    end

    context 'when user has permission(owner) to delete' do
      before do
        @todo_list = create_todo_list(role: :owner)
        create_todo_list(role: :owner) # create two redirect_to index then show
      end

      it { expect { subject }.to change { TodoList.count }.by(-1) }
      it { expect { subject }.to change { EventLog.count }.by(1) }
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          todo_list.log_tag,
          action: 'destroy_todo_list'
        )
        subject
      end
      it { expect(subject).to redirect_to todo_lists_path }
      it do
        subject
        follow_redirect!
        follow_redirect!
        expect(response.body).to include "List #{@todo_list.name} is deleted!"
      end
    end
  end
end
