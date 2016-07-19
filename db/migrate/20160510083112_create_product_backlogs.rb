class CreateProductBacklogs < ActiveRecord::Migration
  def change
    create_table :product_backlogs do |t|
      t.string :category
      t.string :story
      t.integer :priority
      t.integer :estimate
      t.float :actual
      t.float :remaining
      t.references :project, index: true, foreign: true
      t.references :sprint, index: true, foreign: true

      t.timestamps null: false
    end
  end
end
