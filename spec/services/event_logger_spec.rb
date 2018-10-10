# frozen_string_literal: true

require 'rails_helper'

describe EventLogger do
  describe 'self.log' do
    let(:todo_list) { create(:todo_list) }
    let(:user) { create(:user1) }

    context 'when invalid action' do
      subject { EventLogger.log(resource: todo_list, user: user, action: :invalid) }
      it { expect { subject }.to raise_error(ArgumentError, 'Invalid Action') }
    end

    context 'give all arguments' do
      subject do
        todo_list.name = 'changed name'
        EventLogger.log(
          resource: todo_list,
          user: user,
          action: :create,
          tag: 'some tag',
          description: 'some description',
          changes: todo_list.changes
        )
      end

      it 'create log for resource with user action' do
        expect { subject }.to change { EventLog.count }.by(1)

        log = EventLog.last
        expect(log.resourceable).to eq todo_list
        expect(log.user).to eq user
        expect(log.action).to eq 'create'
        expect(log.log_tag).to eq 'some tag'
        expect(log.description).to eq 'some description'
        expect(log.variation).to eq todo_list.changes
      end
    end

    context 'default behavior for nil argument' do
      subject { EventLogger.log(resource: todo_list, user: user, action: :create) }

      it { expect(subject.log_tag).to eq "todo_list_#{todo_list.id}" }
      it { expect(subject.description).to eq "#{user.name} create a todo_list" }
      it { expect(subject.variation).to eq({}) }
    end
  end
end
