class RfmController < ApplicationController
    respond_to :html, :xml, :json

    def index
    end

    def monetary_customer_distribution
        monetary_ranges = [1..500, 501..2000 , 2001..4000, 4001..10000]
        distribution = Spree::User.monetary_distribution(monetary_ranges)
        data = create_chart_data(distribution, :products_sold_for_price_range)
        json_response = Report.new('Price Range', labels_for_order_value(monetary_ranges).values, data, colors[0]).to_json
        respond_with(json_response)
    end

    def recency_customer_distribution
        recency_ranges_in_days = [0..7, 8..30, 31..80]
        distribution = Spree::User.recency_distribution(recency_ranges_in_days)
        data = create_chart_data(distribution, :products_sold_in_date_range)
        json_response = Report.new('Recency In Days', labels_for_order_value(recency_ranges_in_days).values, data, colors[0]).to_json
        respond_with(json_response)
    end

    def frequency_customer_distribution
        transactions_frequency_range = [1..1, 2..3, 4..5, 6..10, 10..99999]
        distribution = Spree::User.frequency_distribution(transactions_frequency_range)
        data = create_chart_data(distribution, :products_by_transaction_frequency)
        json_response = Report.new('Number Of Orders', labels_for_order_value(transactions_frequency_range).values, data, colors[0]).to_json
        respond_with(json_response)
    end

    private
    def create_chart_data(distribution, products_range_call)
        index = 0
        data = distribution.keys.map do |range|
            color = colors[index]
            index += 1
            products = Spree::Product.send(products_range_call, range)
            drilldown_data = Report.new(range.to_s, products[:product_names], products[:data], color)
            { :y => distribution[range], :color => color , :drilldown => drilldown_data }
        end
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
