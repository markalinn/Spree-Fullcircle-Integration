require 'active_record'
require 'spree'

namespace :spree_fullcircle_integration do
  desc "Import and Export"
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
          product.company_num = company_num
          product.upc_code = upc_code
          product.product_code = product_code
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
          inventory.product_code = product_code
          inventory.color = color
          inventory.size_type = size_type
          inventory.size = size
          inventory.quantity = quantity
          inventory.available_date = available_date
          inventory.save
        end
    end

  end

end