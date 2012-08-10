module Spree
  Variant.class_eval do
    has_one :fullcircle_product, :class_name => "FullcircleProduct", :primary_key => "sku", :foreign_key => 'product_code'
    has_one :fullcircle_variant, :class_name => "FullcircleVariant", :primary_key => "sku", :foreign_key => 'upc_code'
    has_one :fullcircle_inventory, :class_name => "FullcircleInventory", :foreign_key => "upc_code", :primary_key => 'sku'
    
    def count_on_hand
      fullcircle_inventory ? fullcircle_inventory.quantity.to_i : 0
    end
  
    def price
      fullcircle_variant ? fullcircle_variant.price.to_f : 1000
    end
    
    def weight
      fullcircle_variant ? fullcircle_variant.weight.to_i : 10
    end
  end
end