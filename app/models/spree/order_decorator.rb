module Spree
  Order.class_eval do
    require 'csv'


    # OVERRIDING finalize method usually defined by spree_core-1.0.0
    # Finalizes an in progress order after checkout is complete.
    # Called after transition to complete state when payments will have been processed
    def finalize!
      update_attribute(:completed_at, Time.now)
      InventoryUnit.assign_opening_inventory(self)
      # lock any optional adjustments (coupon promotions, etc.)
      adjustments.optional.each { |adjustment| adjustment.update_attribute('locked', true) }
      OrderMailer.confirm_email(self).deliver

      self.state_events.create({
        :previous_state => 'cart',
        :next_state     => 'complete',
        :name           => 'order' ,
        :user_id        => (User.respond_to?(:current) && User.current.try(:id)) || self.user_id
      })
      
      #New addition - create order file for fullcircle to pick up
      self.create_fullcircle_file      
    end

    def create_fullcircle_file
      
      self.line_items.each do |order_line_item|  
        # The following is the order of the tab delimited fields
        #####################
        #Company Number (required)
        fc_company_number = '01'
        #FCCustomerID
        #CustomerID
        #CustomerType
        #OrderNumber (required)
        fc_order_number = self.number
        #PONumber
        #OrderDate (recommended)
        fc_order_date = self.completed_at.strftime("%m/%d/%Y")
        #ShipDate -
        #CancelDate -
        #OrderType
        #PaymentType
        #Transaction ID
        #Authorization Code
        #ChargeCard
        #CreditCardNumber
        #CardExpDate
        #SecurityCode
        #Line
        #UPC Code (required)
        fc_upc_code = order_line_item.variant.sku
        #Style
        #Color
        #Size Type
        #Size
        #CurrencyCode
        #UnitPrice (required)
        fc_unit_price = order_line_item.price
        #Quantity (required)
        fc_quantity = order_line_item.quantity
        #ShipToAddressID
        #ShipToName (required)
        fc_shipto_name = self.ship_address.firstname + ' ' + self.ship_address.lastname
        #ShipToAddress1 (required)
        fc_shipto_address1 = self.ship_address.address1
        #ShipToAddress2
        fc_shipto_address2 = self.ship_address.address2
        #ShipToAddress3
        #ShipToCity (required)
        fc_shipto_city = self.ship_address.city
        #ShipToState (required)
        fc_shipto_state = self.ship_address.state.abbr
        #ShipToZip (required)
        fc_shipto_zip = self.ship_address.zipcode
        #ShipToCountry (required)
        fc_shipto_country = self.ship_address.country.iso3
        #ShipToPhone
        fc_shipto_phone = self.ship_address.phone
        #ShipToEmail
        #ShipMethod (required)
        fc_ship_method = self.shipping_method.fullcircle_code
        #SpecialInstruction
        #BillToAddressID
        #BillToName (required)
        fc_billto_name = self.bill_address.firstname + ' ' + self.bill_address.lastname
        #BillToAddress1 (required)
        fc_billto_address1 = self.bill_address.address1
        #BillToAddress2
        fc_billto_address2 = self.bill_address.address2
        #BillToAddress3
        #BillToCity (required)
        fc_billto_city = self.bill_address.city
        #BillToState (required)
        fc_billto_state = self.bill_address.state.abbr
        #BillToZip (required)
        fc_billto_zip = self.bill_address.zipcode
        #BillToCountry (required)
        fc_billto_country = self.bill_address.country.iso
        #BillToPhone
        fc_billto_phone = self.bill_address.phone
        #TaxCode
        #FreightCharges (recommended)
        # This is incorrect, need to figure out how to just get freight charge.....fc_freight =  self.adjustment_total
        #Discount
        #MailingListStatus
        #Web Account Login
        #First Name
        #Last Name
        #Middle Initial
        #Gender
        #Company
        #Position (Title)
        #Market
        #Price Level
        #Phone Number
        #Receives Emails
        #Printed Catalog
        #Catalog Source
        #Div/Lab Access
        #Embellishment Code
        #Embellishment Desc 1
        #Embellishment Desc 2
        #Embellishment Desc 3
        #Embellishment Desc 4
        #Embellishment Price
        #Source Code
        #Tax Percent
        File.open('OrderExport.txt', 'a+') { |f|
          f.write("#{fc_company_number}\t\t\t\t#{fc_order_number}\t\t#{fc_order_date}\t\t\t\t\t\t\t\t\t\t\t\t#{fc_upc_code}\t\t\t\t\t\t#{fc_unit_price}\t#{fc_quantity}\t\t#{fc_shipto_name}\t#{fc_shipto_address1}\t#{fc_shipto_address2}\t\t#{fc_shipto_city}\t#{fc_shipto_state}\t#{fc_shipto_zip}\t#{fc_shipto_country}\t#{fc_shipto_phone}\t\t#{fc_ship_method}\t\t\t#{fc_billto_name}\t#{fc_billto_address1}\t#{fc_billto_address2}\t\t#{fc_billto_city}\t#{fc_billto_state}\t#{fc_billto_zip}\t#{fc_billto_country}\t#{fc_billto_phone}\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n")
        }
      end
    end    

  end
end