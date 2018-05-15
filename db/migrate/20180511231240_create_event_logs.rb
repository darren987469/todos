class CreateEventLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :event_logs do |t|
      t.references :resourceable, polymorphic: true, index: true
      t.references :user, index: true
      t.string :log_tag, index: true
      t.string :action
      t.string :description
      t.jsonb :variation

      t.timestamps
    end
  end
end
