Spree::Variant.instance_eval do
    def product_id(variant_id)
        Spree::Variant.find_by_id(variant_id, :select => :product_id).product_id
    end
end
