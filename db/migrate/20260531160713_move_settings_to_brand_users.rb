class MoveSettingsToBrandUsers < ActiveRecord::Migration[8.0]
  def up
    remove_index :settings, name: "index_settings_on_brand_id_and_user_id"
    execute "DELETE FROM settings"
    remove_reference :settings, :brand, foreign_key: true
    remove_reference :settings, :user, foreign_key: true
    add_reference :settings, :brand_user, null: false, foreign_key: true, index: { unique: true }
  end

  def down
    execute "DELETE FROM settings"
    remove_reference :settings, :brand_user, foreign_key: true
    add_reference :settings, :brand, null: false, foreign_key: true
    add_reference :settings, :user, null: false, foreign_key: true
    add_index :settings, [ :brand_id, :user_id ], unique: true
  end
end
