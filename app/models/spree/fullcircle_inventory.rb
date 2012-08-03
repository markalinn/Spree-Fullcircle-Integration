module Spree
  class FullcircleInventory < ActiveRecord::Base
    set_primary_key 'upc_code'

    belongs_to :fullcircle_product, :class_name => 'FullcircleProduct', :foreign_key => 'upc_code'
    belongs_to :variant, :class_name => 'Variant', :foreign_key => 'sku'

    validates_presence_of :upc_code, :quantity
    validates_uniqueness_of :upc_code
  end
end