module Admin
  class AssortmentMapController < ApplicationController
    respond_to :json, :html

    def index
      #taxon_id = params[:taxon_id]
      taxon_id = 558398391
      product_ids = Admin::ProductWeeklySales.select(:product_id).uniq.map { |pws| pws.product_id }
      

      product_weely_sales_by_taxon_id = Admin::ProductWeeklySales.by_taxon_id(taxon_id)
      
      revenue = product_weely_sales_by_taxon_id[product_ids[0]]["total_Revenue"]
      revenue1 = product_weely_sales_by_taxon_id[product_ids[1]]["total_Revenue"]
      revenue2 = product_weely_sales_by_taxon_id[product_ids[2]]["total_Revenue"]
      revenue3 = product_weely_sales_by_taxon_id[product_ids[2]]["total_Revenue"]
      
      
      @data = [{ "id" => '#ff0000', "value" => revenue, "label" => "haha", "color" => '#ff0000'},
               {"id" => '#ff00', "value" => revenue1, "label" => "haha", "color" => '#00ff00'},
               {"id" => '#ff000', "value" => revenue2, "label" => "haha", "color" => '#c0ff00'},
               {"id" => 1234, "value" => revenue3, "label" => "haha", "color" => '#c0c000'}].to_json
      respond_with(@data)
    end
  end
end