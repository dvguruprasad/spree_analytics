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
                behavior.products.each do |bought_product|
                    product_category = category(bought_product)
                    stack[product_category] ||= []
                    stack[product_category].pop # assumption: last search was for the purchase
                    next if stack[product_category].empty?
                    if(is_an_upsell(stack[product_category].last, bought_product, behavior.order))
                        substitutions[substitution(stack[product_category].last.product, bought_product)] += 1
                        stack[product_category].clear
                    end
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
