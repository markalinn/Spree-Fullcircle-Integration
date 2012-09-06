module Spree
  class FullcircleVariant < ActiveRecord::Base
    set_table_name 'spree_fullcircle_products'
    #set_primary_key 'upc_code'

    has_one :fullcircle_inventory, :class_name => 'FullcircleInventory', :foreign_key => 'upc_code', :primary_key => 'upc_code'
    belongs_to :variant, :class_name => 'Variant', :primary_key => 'sku', :foreign_key => 'upc_code'
    has_one :product, :through => :variant
    #Images are only relevant if pre-loading images through rake task to speed up page creation
    has_many :images, :as => :viewable, :order => :position, :dependent => :destroy

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