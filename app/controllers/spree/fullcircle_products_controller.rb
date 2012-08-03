module Spree
  class FullcircleProductsController < BaseController

    respond_to :json
   
    def show
      @fullcircle_product = FullcircleProduct.find_by_upc_code(params[:id])
      render :json => @fullcircle_product.to_json
    end
  
  end
end
