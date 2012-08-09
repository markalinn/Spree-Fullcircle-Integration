class AddUpcCodeToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :upc_code, :string
  end
end
