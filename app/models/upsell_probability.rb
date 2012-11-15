class UpsellProbability < SubstitutionProbability
    def self.find_upsells_for(product)
        upsells = []
        possible_upsells = where('searched_product = ?', product.id).order('probability DESC')
        possible_upsells.each do |possible_upsell|
            break if upsells.count == 5
            bought_product = Spree::Product.find(possible_upsell.bought_product)
            substitute_product_price = price(bought_product)
            searched_product_price = price(product)
            if substitute_product_price > searched_product_price
                upsells << bought_product
            end
        end
        upsells
    end

    private
    def self.price(product)
        product.variants.empty? ? product.master.price : product.least_priced_variant.price
    end
end
