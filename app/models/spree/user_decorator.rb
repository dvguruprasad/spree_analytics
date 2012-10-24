Spree.user_class.instance_eval do
    def monetary_distribution(ranges)
        order_value_frequency = {}
        ranges.each do |range|
            order_value_frequency[range] = 0
        end
        users = all_users
        order_values_by_user = users.map do |u|
            orders_of_user = orders.select {|o| o[:user_id] == u[:user_id]}
            {:user_id => u[:user_id], :average_order_value => average(orders_of_user),
                :transactions => orders_of_user}
        end

        order_values_by_user.each do |ov|
            order_value_frequency.keys.each do |ovf|
                value = ov[:average_order_value]
                if value >= ovf.begin && value <= ovf.end
                    order_value_frequency[ovf] += 1
                end
            end
        end
        convert_to_percentage(order_value_frequency, users.length)
    end

    def recency_distribution(recency_ranges)
        distribution = {}
        recency_ranges.each do |range|
            distribution[range] = 0
            distribution[range] += count_of_users_in_recency_range(range)
        end
        convert_to_percentage(distribution, all_users.length)
    end

    def frequency_distribution(ranges)
        distribution = {}
        ranges.each do |range|
            distribution[range] = 0
            distribution[range] += count_of_users_in_transaction_frequency_range(range)
        end
        convert_to_percentage(distribution, all_users.length)
    end

    private
    def all_users
        @users ||= Spree.user_class.find(:all, :select => "id").map {|u| {:user_id => u.id }}
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
        to = Date.today - range.begin
        query = <<-HERE
                select count(distinct(user_id)) as customer_count from spree_orders where created_at >= '#{from}' and created_at < '#{to}'
        HERE
        ActiveRecord::Base.connection.execute(query).first[0]
    end

    def count_of_users_in_transaction_frequency_range(range)
        from = Date.today - range.end
        to = Date.today - range.begin
        query = <<-HERE
               select count(*) from (select count(*) customer_count from spree_orders o group by o.user_id having customer_count >= #{range.begin} and customer_count < #{range.end}) AS DERIVED
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
    def substitutions_since(last_capture_timestamp)
        behaviors = UserBehavior.find(:all, :conditions => ["user_id = ? and created_at > ?", id, last_capture_timestamp])
        behaviors = [] if behaviors.nil?
        stack = []
        substitutions_hash = Hash.new(0)
        behaviors.each do |behavior|
            if behavior.searched_and_not_available?
                stack.pop if !stack.empty?
                stack << behavior
            elsif behavior.purchase?
                if !stack.empty? && is_a_substitution(stack.first.product, behavior.product)
                    searched_product = stack.pop.product
                    bought_product = behavior.product
                    count = substitutions_hash[substitution(searched_product, bought_product)]
                    substitutions_hash[substitution(searched_product, bought_product)]  = count + 1
                end
            end
        end
        substitutions_hash.collect {|s,c| s.count = c; s}
    end

    def is_a_substitution(searched, bought)
        searched_product = Spree::Product.find_by_id(searched)
        bought_product = Spree::Product.find_by_id(bought)
        searched_product.category_taxon == bought_product.category_taxon
    end

    def substitution(searched_product, bought_product)
        substitution = SubstitutionCount.new
        substitution.searched_product = searched_product
        substitution.bought_product = bought_product
        substitution
    end
end
