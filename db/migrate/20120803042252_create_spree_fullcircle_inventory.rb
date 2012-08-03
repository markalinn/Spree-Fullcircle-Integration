class CreateSpreeFullcircleInventory < ActiveRecord::Migration
  def up
    create_table :spree_fullcircle_inventories do |t|
      t.string :company_num
      t.string :upc_code
      t.string :product_code
      t.string :color
      t.string :size_type
      t.string :size
      t.integer :quantity
      t.datetime :available_date

      t.timestamps
    end
  end

  def down
    drop_table :spree_fullcircle_inventories
  end
end
