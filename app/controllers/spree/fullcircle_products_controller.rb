module Spree
  class FullcircleProductsController < BaseController

    respond_to :json
   
    def show
      @fullcircle_product = FullcircleProduct.find(:first, :conditions => { :product_code => params[:id] })
      render :json => @fullcircle_product.to_json
    end
  
  end
end
