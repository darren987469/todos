require 'rails_helper'

describe Entity::V1::EventLog do
  let(:user) { create(:user1) }
  let(:todo_list) do
    create(:todo_list).tap do |todo_list|
      create(:todo_listship, user: user, todo_list: todo_list, role: :owner)
    end
  end
  let(:event_log) { create(:log, resourceable: todo_list, user: user, action: 'create', description: 'description', log_tag: todo_list.log_tag) }

  subject { described_class.new(event_log).as_json }

  it { expect(subject[:todo_list_id]).to eq todo_list.id }
  it { expect(subject[:resource]).to eq event_log.resourceable_type }
  it { expect(subject[:resource_id]).to eq event_log.resourceable_id }
  it { expect(subject[:user_id]).to eq event_log.user_id }
  it { expect(subject[:action]).to eq event_log.action }
  it { expect(subject[:description]).to eq event_log.description }
end
