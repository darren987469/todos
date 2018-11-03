class ChangeTokensColumn < ActiveRecord::Migration[5.2]
  def change
    change_table :tokens do |t|
      t.remove :scopes
      t.column :scopes, :jsonb
    end
  end
end
