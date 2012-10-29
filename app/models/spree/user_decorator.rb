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
        behaviors = UserBehavior.all_user_behavior_since(id, last_capture_timestamp)
        stacks = Hash.new
        substitutions_hash = Hash.new(0)
        behaviors.each do |behavior|
            if behavior.searched_and_not_available?
                category = category(behavior.product)
                stacks[category] ||= []
                stacks[category].pop if !stacks[category].empty?
                stacks[category] << behavior
            elsif behavior.purchase?
                products_by_category = products_grouped_by_category(behavior.products)
                products_by_category.each do |category, products|
                    next if stacks[category].nil? || stacks[category].empty?
                    products.each do |p|
                        searched_product = stacks[category].first.product
                        if is_a_substitution(searched_product, p)
                            substitutions_hash[substitution(searched_product, p)]  += 1
                        end
                    end
                    stacks[category].pop
                end
            end
        end
        substitutions_hash.collect {|s,c| s.count = c; s}
    end

    def is_loyal?
        orders.count(:conditions  => ["state=? and completed_at IS NOT NULL","complete"]) > 1
    end

    private
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

    def products_grouped_by_category(products)
        result = {}
        products.each do |p|
            c = category(p)
            result[c] ||= []
            result[c] << p
        end
        result
    end

    def category(product_id)
        Spree::Product.find_by_id(product_id).category_taxon
    end
end
