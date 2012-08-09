module Spree
  Product.class_eval do
    has_one :fullcircle_product, :through => :master
    has_one :fullcircle_inventory, :through => :master
    #Removed this attempt at trying not to create duplicates!
    #This proved to re-enable ol product info that was undesired and a fresh page was wanted anyways.
    #May consider re-enabling in the future. So kept the method available.
    #before_create :find_existing_deleted_sku
    
    after_create :create_fullcircle_option_types
    after_create :create_fullcircle_option_values
    
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

    def create_fullcircle_option_types
      size_option_type = OptionType.find_by_name('fullcircle_size')
      if ! size_option_type
        size_option_type = OptionType.new
        size_option_type.name = 'fullcircle_size'
        size_option_type.presentation = 'Size'
        size_option_type.save
      end
      product_size_option = self.product_option_types.new
      product_size_option.option_type = size_option_type
      product_size_option.save

      color_option_type = OptionType.find_by_name('fullcircle_color')
      if ! color_option_type
        color_option_type = OptionType.new
        color_option_type.name = 'fullcircle_color'
        color_option_type.presentation = 'Color'
        color_option_type.save
      end
      product_color_option = self.product_option_types.new
      product_color_option.option_type = color_option_type
      product_color_option.save
    end
    
    def create_fullcircle_option_values
      size_option_type = OptionType.find_by_name('fullcircle_size')
      color_option_type = OptionType.find_by_name('fullcircle_color')

      fullcircle_variants = FullcircleProduct.find(:all, :conditions => {:product_code => self.sku})
      fullcircle_variants.each do |fullcircle_variant|
        color_option_value = color_option_type.option_values.find(:first, :conditions => {:name => fullcircle_variant.color_code})
        if ! color_option_value
          color_option_value = color_option_type.option_values.new
          color_option_value.name = fullcircle_variant.color_code
          color_option_value.presentation = fullcircle_variant.color_desc
          color_option_value.save
        end
        size_option_value = size_option_type.option_values.find(:first, :conditions => {:name => fullcircle_variant.size})
        if ! size_option_value
          size_option_value = size_option_type.option_values.new
          size_option_value.name = fullcircle_variant.size
          size_option_value.presentation = fullcircle_variant.size
          size_option_value.save
        end
      end
    end

    def link_fullcircle_variants
      fullcircle_variants = FullcircleProduct.find_by_product_code(self.sku)
      fullcircle_variants.each do |fullcircle_variant|
        existing_variant = Variant.find_by_sku(fullcircle_variant.upc_code.strip)
        if ! existing_variant
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