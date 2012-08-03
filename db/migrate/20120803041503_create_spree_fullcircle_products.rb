class CreateSpreeFullcircleProducts < ActiveRecord::Migration
  def up
    create_table :spree_fullcircle_products do |t|
      t.string :company_num
      t.string :upc_code
      t.string :product_code
      t.string :description
      t.string :division_code
      t.string :division_desc
      t.string :color_code
      t.string :color_desc
      t.string :size_type
      t.string :size
      t.decimal :price, :precision => 8, :scale => 2, :null => false, :default => 0.00
      t.integer :weight
      t.string :long_desc
      t.string :technical_desc

      t.timestamps
    end
  end

  def down
    drop_table :spree_fullcircle_products
  end
end
