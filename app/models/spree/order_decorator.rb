Spree::Order.class_eval do
    def products
        line_items.map do |line_item|
            line_item.variant.product
        end
    end
end
