class RfpController < ApplicationController
    respond_to :html, :xml, :json

    def index
    end

    def order_value_to_product
        order_value_ranges = [1..500, 501..2000 , 2001..4000, 4001..10000]
        distribution = UserNew.order_value_frequency_distribution(order_value_ranges)
        sorted_values = order_value_ranges.map {|range| { :range => range, :customer_count => distribution[range] }}
        index = 0

        data = sorted_values.each_with_index.map do |value,index|
            color = colors[index]
            products = ProductNew.products_sold_for_price_range(value[:range])
            drilldown_data = Report.new(value[:range].to_s, products[:product_names], products[:data], color)
            { :y => value[:customer_count] , :color => color , :drilldown => drilldown_data }
        end


        json_response = Report.new('Price Range', labels_for_order_value(order_value_ranges).values, data, colors[0]).to_json
        respond_with(json_response)
    end

    def colors
        ["#4572A7", "#AA4643", "#89A54E", "#80699B", "#3D96AE", "#DB843D", "#92A8CD", "#A47D7C", "#B5CA92"]
    end

    def labels_for_order_value(ranges)
        labels = {}
        ranges.each_with_index do |r,index|
            labels[index] = r.to_s
        end
        labels
    end
end
