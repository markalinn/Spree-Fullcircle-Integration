require 'active_record'
require 'spree'

namespace :spree_fullcircle_integration do
  desc "Import fullcircle files"
  task :import do
    Rake::Task['spree_fullcircle_integration:import:products'].invoke
    Rake::Task['spree_fullcircle_integration:import:inventory'].invoke
  end

  namespace :import do
    desc "Imports Fullcircle Products"
    task :products => :environment do
      puts "Importing Fullcircle Files"
        File.open("01_products.txt", "r").each do |line|
          company_num, upc_code, product_code, description, division_code, division_desc, color_code, color_desc, size_type, size, price, weight, long_desc, technical_desc = line.strip.split("\t")
          puts "  Importing UPC- " + upc_code
          product = Spree::FullcircleProduct.find_by_upc_code(upc_code)
          if ! product
            product = Spree::FullcircleProduct.new
          end
          product.company_num = company_num.strip
          product.upc_code = upc_code
          product.product_code = product_code.strip
          product.description = description
          product.division_code = division_code
          product.division_desc = division_desc
          product.color_code = color_code
          product.color_desc = color_desc
          product.size_type = size_type
          product.size = size
          product.price = price
          product.weight = weight
          product.long_desc = long_desc
          product.technical_desc = technical_desc
          product.save
        end
    end

    desc "Imports Fullcircle Inventory"
    task :inventory => :environment do
      puts "Importing Fullcircle Inventory"
        File.open("01_inventory.txt", "r").each do |line|
          company_num, upc_code, product_code, color, size_type, size, quantity, available_date = line.strip.split("\t")
          puts "  Importing UPC- " + upc_code
          inventory = Spree::FullcircleInventory.find_by_upc_code(upc_code)
          if ! inventory
            inventory = Spree::FullcircleInventory.new
          end
          inventory.company_num = company_num
          inventory.upc_code = upc_code
          inventory.product_code = product_code.strip
          inventory.color = color
          inventory.size_type = size_type
          inventory.size = size
          inventory.quantity = quantity
          inventory.available_date = available_date
          inventory.save
        end
    end

    desc "Links Staged Images to Fullcircle Products"
    task :images => :environment do
      puts "Linking Fullcircle Images"
        images_file_path = File.join(Rails.root, 'public', 'system', 'images', '/')
        completed_file_path = File.join(images_file_path, 'processed', '/')
        local_image_files = Dir.glob(images_file_path + '*.jpg')
        local_image_files.each do |image_file|
          begin
            image_file_name = image_file.split(images_file_path)[1].to_s.upcase
            image_file_prefix= image_file_name.split(".jpg")[0]
            image_product_code = image_file_prefix.split("_")[0]
            image_color_code = image_file_prefix.split("_")[1]
            begin
              image_position = image_file_prefix.split("_")[2].to_i
            rescue
              image_position = 0
            end
            msg = " Processing: " + image_file_name
            msg = msg +  " >> "
            msg = msg + image_product_code
            msg = msg +  "-"
            msg = msg + image_color_code
            puts msg
            fullcircle_variants = Spree::FullcircleVariant.find(:all, :conditions => {:product_code => image_product_code, :color_code => image_color_code})
            variant_default_image_count = 0
            fullcircle_variants.each do |fullcircle_variant|
              fullcircle_variant_image = fullcircle_variant.images.find(:first, :conditions => {:position => image_position}, :order => 'position')
              if ! fullcircle_variant_image
                  #if position image doesn't exist then import
                  fullcircle_image = fullcircle_variant.images.new
                  image = File.open(image_file,  "r")
                  fullcircle_image.attachment = image
                  fullcircle_image.position = image_position
                  fullcircle_image.save
                  #if image is the first image for this color then also create a default image
                  if variant_default_image_count < 1 && image_position < 2
                    #Find master product and attach this first color image
                    puts "    Saving Default Image for product - " + image_product_code
                    product = Spree::FullcircleProduct.find(:first, :conditions => {:product_code => image_product_code})
                    product_image = product.images.new
                    product_image.attachment = image
                    product_image.position = image_position
                    product_image.save
                    variant_default_image_count = variant_default_image_count + 1                  
                  end
                  #Increment varaint counter to determine number of size variants for this color 
              end
            end
            FileUtils.mkdir(completed_file_path) unless File.directory?(completed_file_path)
            FileUtils.mv(image_file,completed_file_path)
          rescue
            puts "Error importing file - " + image_file
          end
        end
    end

  end

end