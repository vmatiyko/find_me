class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.references :brand, null: false, foreign_key: true
      t.string :key, null: false
      t.string :value, null: false, default: ""

      t.timestamps
    end

    add_index :settings, [ :brand_id, :key ], unique: true
  end
end
