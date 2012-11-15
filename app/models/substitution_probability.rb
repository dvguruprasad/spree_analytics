class SubstitutionProbability < ActiveRecord::Base
    self.table_name = "spree_substitution_probabilities"

    attr_accessible :searched_product,:bought_product, :probability

    def self.create_or_update_probability(searched, bought, probability)
        substitution = find_or_create_by_searched_product_and_bought_product(searched, bought)
        substitution.probability = probability
        substitution.save
    end

    def self.top_substitutes_for(product)
        return {} if product.nil?
        substitution_probabilities = find(:all, :conditions => ["searched_product = ?", product.id],
                                          :order => "probability DESC", :limit => 5)
        substitution_probabilities.map{|p| {:product => Spree::Product.find_by_id(p.bought_product), :probability => p.probability}}
    end

    def self.generate_for_oos_substitution
        generate_probabilities(OOSSubstitutionProbability, OOSSubstitution)
    end

    def self.generate_for_upsell
        generate_probabilities(UpsellProbability, Upsell)
    end

    private
    def self.generate_probabilities(probability_kind, substitution_kind)
        substitutions = substitution_kind.find(:all)
        substitutions.each do |substitution|
            search_count = UserBehavior.search_count(substitution.searched_product, is_available = (substitution_kind == Upsell))
            next if search_count == 0
            probability = substitution.count / search_count.to_f
            probability_kind.create_or_update_probability(substitution.searched_product, substitution.bought_product, probability)
            Rails.logger.info "#{substitution_kind} probability of #{substitution.searched_product} with #{substitution.bought_product} is #{probability}"
        end
    end
end
