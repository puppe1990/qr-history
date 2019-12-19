class CreateSales < ActiveRecord::Migration[6.0]
  def change
    create_table :sales do |t|
      t.integer :quantity
      t.float :price
      t.float :total
      t.string :status
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
