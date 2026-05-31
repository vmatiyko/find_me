class AddUserToSettings < ActiveRecord::Migration[8.0]
  def up
    remove_index :settings, name: "index_settings_on_brand_id_and_key"
    add_reference :settings, :user, null: false, foreign_key: true
    add_index :settings, [ :brand_id, :user_id ], unique: true
  end

  def down
    remove_index :settings, name: "index_settings_on_brand_id_and_user_id"
    remove_reference :settings, :user, foreign_key: true
    add_index :settings, [ :brand_id, :key ], unique: true
  end
end
