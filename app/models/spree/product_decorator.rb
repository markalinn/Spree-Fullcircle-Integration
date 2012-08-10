module Spree
  Product.class_eval do
    has_one :fullcircle_product, :through => :master
    has_one :fullcircle_inventory, :through => :master
    #Removed this attempt at trying not to create duplicates!
    #This proved to re-enable ol product info that was undesired and a fresh page was wanted anyways.
    #May consider re-enabling in the future. So kept the method available.
    #before_create :find_existing_deleted_sku
    
    after_create :create_fullcircle_option_types
    after_create :create_fullcircle_variants
    
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
    end
    
    def create_fullcircle_variants
      size_option_type = OptionType.find_by_name('fullcircle_size')
      color_option_type = OptionType.find_by_name('fullcircle_color')
      image_count = 0

      fullcircle_variants = FullcircleVariant.find(:all, :conditions => {:product_code => self.sku})
      fullcircle_variants.each do |fullcircle_variant|
        #Setup Option Values if they don't exist
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

        #Create product variant
        product_variant = Variant.find(:first, :conditions => {:sku => fullcircle_variant.upc_code, :deleted_at => nil})
        if ! product_variant
          product_variant = self.variants.new
        end
        product_variant.is_master = false
        product_variant.sku = fullcircle_variant.upc_code
        product_variant.price = 1000
        product_variant.count_on_hand = 1
        product_variant.save
        
        #Lookup and link option_values to variant
        variant_size_option_value = OptionValuesVariant.find(:first, :conditions => {:option_value_id => size_option_value.id, :variant_id => product_variant.id})
        if ! variant_size_option_value
          variant_size_option_value = OptionValuesVariant.create!(:option_value_id => size_option_value.id, :variant_id => product_variant.id)
        end
        variant_color_option_value = OptionValuesVariant.find(:first, :conditions => {:option_value_id => color_option_value.id, :variant_id => product_variant.id})
        if ! variant_color_option_value
          variant_color_option_value = OptionValuesVariant.create!(:option_value_id => color_option_value.id, :variant_id => product_variant.id)
        end

        #Link Product Image to Variant if it exists!
        image_product_code = fullcircle_variant.product_code
        image_color_code = fullcircle_variant.color_code
        image_file_prefix = image_product_code + "_" + image_color_code
        
        image_file_path = File.join(Rails.root, 'public', 'system', 'images', image_file_prefix)
        local_image_files = Dir.glob(image_file_path + '_*')
        local_image_files.each do |image_file|
          image_file = File.open(image_file,  "r")
          if image_count < 2
            variant_image = product_variant.product.images.new
          else
            variant_image = product_variant.images.new
          end
          variant_image.attachment = image_file
          variant_image.save
          image_count = image_count + 1
        end
#        begin
#          image_file = File.open(image_file_path,  "r")
#          variant_image = product_variant.images.new
#          variant_image.attachment = image_file
#          variant_image.save
#        rescue
          #Unable to open file for some reason
#        end
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