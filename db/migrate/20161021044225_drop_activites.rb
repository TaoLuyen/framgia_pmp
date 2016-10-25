class DropActivites < ActiveRecord::Migration
  def change
    drop_table :activities do |t|
      t.references :product_backlog
      t.string :subject
      t.string :description
      t.integer :spent_time
      t.integer :estimate
      t.integer :user_id
      t.string :task_id
      t.references :sprint

      t.timestamps null: false
    end
  end
end
