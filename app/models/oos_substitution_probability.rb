class OOSSubstitutionProbability < SubstitutionProbability
    def self.find_substitutes_for(product)
        substitutes = top_substitutes_for product
        return [] if substitutes.empty?
        substitutes.first[:product].is_promotional = true if substitutes.first[:probability] > Spree::Config.probability_threshold_for_discounts
        substitutes.map{|s| s[:product]}
    end
end
