class UserNew
    class << self
        def order_value_frequency_distribution(ranges)
            order_value_frequency = {}
            ranges.each do |range|
                order_value_frequency[range] = 0
            end
            order_values_by_user = users.map do |u| 
                orders_of_user = orders.select {|o| o[:user_id] == u[:user_id]}
                {:user_id => u[:user_id], :average_order_value => average(orders_of_user), 
                                            :transactions => orders_of_user}
            end

            order_values_by_user.each do |ov|
                order_value_frequency.keys.each do |ovr|
                    value = ov[:average_order_value]
                    if value >= ovr.begin && value <= ovr.end
                        order_value_frequency[ovr] += 1
                    end
                end
            end
            order_value_frequency
        end

        def users
            users = Spree::User.find(:all, :select => "id").map {|u| {:user_id => u.id }}
            num_users = 100
            users = users[0..(num_users - 1)]
        end

        def orders
            db_orders = Spree::Order.find(:all, :select => "id, total, user_id, created_at")
            Rails.logger.info db_orders.first
            db_orders.map {|o| {:user_id => o.user_id, :order_value => o.total, :date => o.created_at, :id => o.id}}
        end

        def average(orders)
            sum = 0
            orders.each {|o| sum += o[:order_value]}
            orders.length == 0 ? 0 : sum/orders.length
        end
    end
end
