module Spree
  class FullcircleProduct < ActiveRecord::Base
    set_primary_key 'upc_code'

    has_one :fullcircle_inventory, :class_name => 'FullcircleInventory', :foreign_key => 'upc_code'
    has_one :variant, :class_name => 'Variant', :foreign_key => 'sku'
    has_one :product, :through => :variant
    validates_presence_of :upc_code
    validates_uniqueness_of :upc_code
    
    def sku
      sku = product_code.strip + '-' 
      sku = sku + color_code.strip
      sku = sku  + '-'
      sku = sku + size.strip
      return sku
    end
  end
end