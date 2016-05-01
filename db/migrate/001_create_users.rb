class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|
      t.integer :uid
      t.string :first_name
      t.string :last_name
      t.integer :offset, default: 0
      t.timestamps null: true
    end
  end
end
