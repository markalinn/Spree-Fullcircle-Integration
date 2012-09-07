Deface::Override.new(:virtual_path => "spree/admin/products/_form", 
                     :name => "fullcircle_admin_product_form_right", 
                     :replace => "[data-hook='admin_product_form_right']", 
                     :partial => "spree/admin/products/fullcircle_form_right")

Deface::Override.new(:virtual_path => "spree/admin/shipping_methods/_form", 
                     :name => "fullcircle_admin_shipping_methods_form", 
                     :insert_before => "[data-hook='admin_shipping_method_form_fields']", 
                     :partial => "spree/admin/shipping_methods/fullcircle_form")
