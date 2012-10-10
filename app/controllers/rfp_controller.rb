class RfpController < ApplicationController
    respond_to :html, :xml, :json

    def index
    end

    def colors
        ["#4572A7", "#AA4643", "#89A54E", "#80699B", "#3D96AE", "#DB843D", "#92A8CD", "#A47D7C", "#B5CA92"]
    end

    def order_value_to_product
        sorted_values = sorted_ranges.map {|r| { :range => r, :value => order_value_frequency_distribution[r] }}
        index = 0
        labels = {}
        sorted_ranges.each do |r|
            labels[index] = r.to_s
            index += 1
        end

        data = sorted_values.each_with_index.map do |value,index|
            color = colors[index]
            drilldown_data =  products_sold_for_price_range(value[:range],color)
            { :y => value[:value] , :color => color , :drilldown => drilldown_data }
        end


        json_response = Report.new('Price Range', labels_for_order_value.values, data, colors[0]).to_json
        Rails.logger.info "##############JSON: #{json_response}"
        respond_with(json_response)

    end


    def  order_value_wise_product_distribution

        order_valuewise_product_distribution = {1..500 => {},
            501..2000 => {},
            2001..4000 => {},
            4001..10000 => {}
        } 
        orders_of_user = orders.select {|o| o[:user_id] == u[:user_id]}
        order_values_by_user = users.map do |u| 
            orders_of_user = orders.select {|o| o[:user_id] == u[:user_id]}
            {:user_id => u[:user_id], 
                :average_order_value => average(orders_of_user), :transactions => orders_of_user}
        end

        order_values_by_user.each do |ov|
            order_value_frequency_distribution.keys.each do |ovr|
                value = ov[:average_order_value]
                if value >= ovr.begin && value <= ovr.end
                    order_value_frequency_distribution[ovr] = order_value_frequency_distribution[ovr] + 1
                    order_valuewise_transaction_buckets[ovr] = order_valuewise_transaction_buckets[ovr] + ov[:transactions]
                end
            end
        end
        order_valuewise_transaction_buckets.keys.each do |r|
            order_valuewise_transaction_buckets[r].each do |tx|
                tx[:basket].each do |mix|
                    order_valuewise_product_distribution[r][mix[:product]] = 0 if order_valuewise_product_distribution[r][mix[:product]].nil?
                    order_valuewise_product_distribution[r][mix[:product]] = order_valuewise_product_distribution[r][mix[:product]] + 1
                end
            end
        end
        order_valuewise_product_distribution
    end



    def  products_sold_for_price_range(range,color)
        query = <<-HERE
        select spree_products.name, spree_products.id , count(*) as product_count 
        from spree_products join spree_variants on (spree_products.id = spree_variants.product_id ) 
                            join spree_line_items on (spree_line_items.variant_id=spree_variants.id) 
                                and spree_variants.price >=#{range.first} and spree_variants.price <= #{range.last} 
                group by spree_products.id order by product_count desc 
        HERE
        product_names_with_count = ActiveRecord::Base.connection.select_all(query)
        data = in_percentage( product_names_with_count.map {|val|  val["product_count"]  })
        product_names = product_names_with_count.map {|val|  val["name"]  }
        Report.new(range.to_s, product_names, data, color)
    end

    def in_percentage values
        count = values.count
        sum = values.inject(:+)
        values.map{|value|  ((value/sum.to_f) *100).round(2)  }

    end


    def order_value_frequency_distribution
        #if @order_value_frequency.present? return @order_value_frequency
        @order_value_frequency = {1..500 => 0,
            501..2000 => 0,
            2001..4000 => 0,
            4001..10000 => 0
        }
        order_values_by_user = users.map {|u| {:user_id => u[:user_id], :average_order_value => average(orders.select {|o| o[:user_id] == u[:user_id]}), :transactions => orders.select {|o| o[:user_id] == u[:user_id]}}}
        order_values_by_user.each do |ov|
            @order_value_frequency.keys.each do |ovr|
                value = ov[:average_order_value]
                if value >= ovr.begin && value <= ovr.end
                    @order_value_frequency[ovr] = @order_value_frequency[ovr] + 1
                    order_valuewise_transaction_buckets[ovr] = order_valuewise_transaction_buckets[ovr] + ov[:transactions]
                end
            end
        end
        @order_value_frequency
    end

    def line_items
        orders.each do |o|
            line_items = ActiveRecord::Base.connection.execute("select variant_id, quantity from spree_line_items where order_id = #{o[:id]}")
            o[:basket] = line_items.map {|line_item| { :product => products.select {|p| p[:variant_id] == line_item["variant_id"]}[0], :quantity => line_item["quantity"]}}
        end
        line_items
    end

    def sorted_ranges
        order_value_frequency_distribution.keys.sort {|r1, r2| (r1.begin + r1.end)/2 <=> (r2.begin + r2.end)/2}
    end

    def labels_for_order_value
        labels = {}
        sorted_ranges.each_with_index do |r,index|
            labels[index] = r.to_s
        end
        labels
    end

    def users
        db_users = Spree::User.find(:all, :select => "id")
        users = db_users.map {|u| {:user_id => u.id }}
        num_users = 100
        users = users[0..(num_users - 1)]
    end

    def orders
        db_orders = Spree::Order.find(:all, :select => "id, total, user_id, created_at")
        logger.info(db_orders.first)
        db_orders.map {|o| {:user_id => o.user_id, :order_value => o.total, :date => o.created_at, :id => o.id}}
    end

    def average(orders)
        sum = 0
        orders.each {|o| sum += o[:order_value]}
        orders.length == 0 ? 0 : sum/orders.length
    end

    def  order_valuewise_transaction_buckets
        {1..500 => [],
            501..2000 => [],
            2001..4000 => [],
            4001..10000 => []
        }
    end
end
