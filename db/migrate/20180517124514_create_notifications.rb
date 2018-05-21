class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :log, index: true
      t.references :user, index: true
      t.datetime :read_at
    end
  end
end
