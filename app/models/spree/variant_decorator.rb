module Spree
  Variant.class_eval do
    belongs_to :fullcircle_product, :class_name => "FullcircleProduct", :foreign_key => "upc_code"
    has_one :fullcircle_inventory, :class_name => "FullcircleInventory", :foreign_key => "upc_code"
    
    def count_on_hand
      fullcircle_inventory ? fullcircle_inventory.quantity.to_i : 0
    end
  
    def price
      fullcircle_product ? fullcircle_product.price.to_f : 1000
    end
    
  end
end