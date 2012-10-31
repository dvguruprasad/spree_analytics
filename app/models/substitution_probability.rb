class SubstitutionProbability < ActiveRecord::Base
    self.table_name = "spree_substitution_probabilities"

    attr_accessible :searched_product,:bought_product, :probability

    def self.create_or_update_probability(searched, bought, probability)
        substitution = find_or_create_by_searched_product_and_bought_product(searched, bought)
        substitution.probability = probability
        substitution.save
    end

    def self.find_substitutes_for(product)
        return {} if product.nil?
        substitution_probabilities = find(:all, :conditions => ["searched_product = ?", product.id],
                                          :order => "probability DESC", :limit => 5)
        substitution_probabilities.map{|p| {:product => Spree::Product.find_by_id(p.bought_product), :probability => p.probability}}
    end
end
