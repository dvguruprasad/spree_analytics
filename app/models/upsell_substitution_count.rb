class UpsellSubstitutionCount < SubstitutionCount
    def self.last_capture_timestamp
        UpsellSubstitutionIdentificationTimestamp.read_and_update
    end

    def self.identify_substitutions(behaviors)
        substitutions = Hash.new(0)
        stack = []
        behaviors.each do |behavior|
            if behavior.searched_and_available?
                stack << behavior
            elsif behavior.purchase?
                stack.pop # assumption: last search was for the purchase
                next if stack.empty?
                behavior.products.each do |bought_product|
                    if(is_an_upsell(stack.last, bought_product, behavior.order))
                        substitutions[substitution(stack.last.product, bought_product)] += 1
                        stack.clear
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
            line_item.variant.product == bought_product && line_item.price > search_behavior.price
        end
    end

    def self.cost(product)
        Spree::Product.find(product).variants.first.price
    end
end
