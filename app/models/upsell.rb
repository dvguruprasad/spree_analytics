class Upsell < Substitution
    def self.last_capture_timestamp
        UpsellIdentificationTimestamp.read_and_update
    end

    def self.identify_substitutions(behaviors)
        substitutions = Hash.new(0)
        stack = {}
        behaviors.each do |behavior|
            if behavior.searched_and_available?
                product_category = category(behavior.product)
                stack[product_category] ||= []
                stack[product_category] << behavior
            elsif behavior.purchase?
                products_by_category = products_grouped_by_category(behavior.products)
                products_by_category.each do |category, products|
                    stack[category] ||= []
                    products.count.times { stack[category].pop }
                    next if stack[category].empty?
                    products.each do |bought_product|
                        if(is_an_upsell(stack[category].last, bought_product, behavior.order))
                            substitutions[substitution(stack[category].last.product, bought_product)] += 1
                        end
                    end
                    stack[category].clear
                end
            end
        end
        return substitutions.collect {|s, c| s.count = c; s}
    end

    private
    def self.is_an_upsell(search_behavior, bought_product_id, order_id)
        bought_product = Spree::Product.find(bought_product_id)
        order = Spree::Order.find(order_id)
        order.line_items.any? do |line_item|
            product = line_item.variant.product
            product == bought_product && category(search_behavior.product) == product.category_taxon && line_item.price > search_behavior.price
        end
    end

    def self.cost(product)
        Spree::Product.find(product).variants.first.price
    end
end
