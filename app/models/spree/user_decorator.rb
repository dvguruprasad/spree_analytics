Spree.user_class.instance_eval do
    has_many    :product_buy_counts, :class_name => "Recommendation::ProductBuyCount", :foreign_key => "user_id" 

    def find_all_with_atleast_one_purchase
        query = <<-HERE
        select DISTINCT spree_users.* from spree_users RIGHT JOIN spree_product_buy_counts ON spree_users.id=spree_product_buy_counts.user_id;
        HERE
        find_by_sql(query)
    end

    def monetary_distribution(ranges)
        order_value_frequency = {}
        ranges.each do |range|
            order_value_frequency[range] = 0
        end
        users = all_users
        order_values_by_user = order_values_by_users(users)
        order_values_by_user.each do |ov|
            order_value_frequency.keys.each do |ovf|
                value = ov[:average_order_value]
                if value > ovf.begin-1 && value <= ovf.end
                    order_value_frequency[ovf] += 1
                end
            end
        end
        convert_to_percentage(order_value_frequency, all_users_count)
    end

    def recency_distribution(recency_ranges)
        distribution = {}
        recency_ranges.each do |range|
            distribution[range] = 0
            distribution[range] += count_of_users_in_recency_range(range)
        end
        distribution
    end

    def frequency_distribution(ranges)
        distribution = {}
        ranges.each do |range|
            distribution[range] = 0
            distribution[range] += count_of_users_in_transaction_frequency_range(range)
        end
        convert_to_percentage(distribution, all_users_count)
    end

    def order_values_by_users(users)
        users.map do |u|
            orders_of_user = u.orders.map {|o| {:user_id => o.user_id, :order_value => o.total, :date => o.created_at, :id => o.id}}
            {:user_id => u.id, :average_order_value => average(orders_of_user),
             :transactions => orders_of_user}
        end
    end

    def all_users
        @users ||= Spree::Order.select(:user_id).uniq.where("user_id != 'NULL'").map{|o| Spree.user_class.find(o.user_id) }
    end
    private

    def all_users_count
        Spree::Order.select(:user_id).uniq.where("user_id != 'NULL'").length
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

    def count_of_users_in_recency_range(range)
        from = Date.today - range.end
        to = Date.today - range.begin + 1
        state = 'complete'
        query = <<-HERE
                select count(distinct(user_id)) as customer_count from spree_orders where state = '#{state}' and created_at >= '#{from}' and created_at < '#{to}'
        HERE
        ActiveRecord::Base.connection.execute(query).first[0]
    end

    def count_of_users_in_transaction_frequency_range(range)
        from = Date.today - range.end
        to = Date.today - range.begin
        state = 'complete'
        query = <<-HERE
               select count(*) from (select count(*) customer_count from spree_orders o where  o.state = '#{state}' group by o.user_id having customer_count >= #{range.begin} and customer_count < #{range.end}) AS DERIVED
        HERE
        ActiveRecord::Base.connection.execute(query).first[0]
    end

    def convert_to_percentage(distribution, total)
        distribution.keys.each do |key|
            count = distribution[key]
            distribution[key] = ((count / total.to_f) * 100).round(2)
        end
        distribution
    end

end

Spree.user_class.class_eval do
    def substitutions_since(last_capture_timestamp, substitution_kind)
        behaviors = UserBehavior.all_user_behavior_since(id, last_capture_timestamp)
        substitution_kind.identify_substitutions(behaviors)
    end

    def common_products(user)
        user1_pbc = product_buy_counts()
        user2_pbc = user.product_buy_counts()
        user1_product_ids = user1_pbc.collect {|pbc| pbc.product_id}
        user2_product_ids = user2_pbc.collect {|pbc| pbc.product_id}
        user1_product_ids & user2_product_ids
    end

    def has_bought?(product_id)
        Recommendation::ProductBuyCount.count(:conditions => "user_id = #{self.id} AND product_id = #{product_id}") > 0
    end

    def is_loyal?
        orders.count(:conditions  => ["state=? and completed_at IS NOT NULL","complete"]) > 1
    end
end
