class Notification < ApplicationRecord
  belongs_to :log, class_name: 'EventLog'
  belongs_to :user
end
