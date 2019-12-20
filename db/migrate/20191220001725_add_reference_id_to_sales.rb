class AddReferenceIdToSales < ActiveRecord::Migration[6.0]
  def change
    add_column :sales, :reference_id, :string
  end
end
