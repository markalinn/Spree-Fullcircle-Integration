class AddFullcircleCodeToSpreeShippingMethods < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :fullcircle_code, :string
  end
end
