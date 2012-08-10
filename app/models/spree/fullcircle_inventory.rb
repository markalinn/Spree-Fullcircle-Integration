module Spree
  class FullcircleInventory < ActiveRecord::Base
    #set_primary_key 'upc_code'

    belongs_to :fullcircle_product, :class_name => 'FullcircleProduct', :foreign_key => 'upc_code', :primary_key => 'upc_code'
    belongs_to :fullcircle_variant, :class_name => 'FullcircleVariant', :foreign_key => 'upc_code', :primary_key => 'upc_code'
    belongs_to :variant, :class_name => 'Variant', :foreign_key => 'sku', :conditions => {:deleted_at => nil}, :primary_key => 'upc_code'
    has_one :product, :through => :variant

    validates_presence_of :upc_code, :quantity
    validates_uniqueness_of :upc_code
  end
end