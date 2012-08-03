class AddUpcCodeToVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :upc_code, :string
  end
end
