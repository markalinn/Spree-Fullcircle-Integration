module Spree
  Product.class_eval do
    has_one :fullcircle_product, :through => :master
    has_one :fullcircle_inventory, :through => :master
    #Removed this attempt at trying not to create duplicates!
    #This proved to re-enable ol product info that was undesired and a fresh page was wanted anyways.
    #May consider re-enabling in the future. So kept the method available.
    #before_create :find_existing_deleted_sku
    
    validates :sku, :presence => true
    
    def price
      fullcircle_product ? fullcircle_product.price.to_f : 0
    end
  
    def weight
      fullcircle_product ? fullcircle_product.weight.to_f : 0
    end
  
    def count_on_hand
      fullcircle_inventory ? fullcircle_inventory.quantity.to_i : 0
    end

    def product_code
      fullcircle_product ? fullcircle_product.product_code.to_s : ''
    end
  
  private

    def import_missing_variants
      fullcircle_variants = FullcircleProduct.find_by_product_code(self.product_code)
      fullcircle_variants.each do |fullcircle_variant|
        existing_variant = Variant.find_by_sku(fullcircle_variant.upc_code)
        if ! fullcircle_variant.upc_code.strip == self.sku && existing_variant == false
          variant = self.variants.new
          variant.is_master = false
          variant.sku = fullcircle_variant.upc_code
        end
      end
    end
    
    def set_master_upc
      if ! master.upc_code
        fc_product = FullcircleProduct.find(:first, :conditions => {:product_code => self.sku})
        master.upc_code = fc_product.upc_code
        master.save
      end
    end
   
  
    def find_existing_deleted_sku
      if ! self.sku.blank?
        existing_deleted_variant = Variant.find(:first, :joins => :product, :conditions => ['products.deleted_at is not NULL and variants.sku = ?', self.sku], :readonly => false)
        if existing_deleted_variant
          #Don't create, instead re-enable the old deleted sku
          dbconn = self.class.connection_pool.checkout
          dbconn.transaction do
            dbconn.execute("update products set deleted_at = NULL where products.id = #{existing_deleted_variant.product.id}")
          end
          self.class.connection_pool.checkin(dbconn)
          #Return false so creation of new doesn't occur
          false
        end
      end
    end
    
  end
end