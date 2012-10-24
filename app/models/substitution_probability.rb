class SubstitutionProbability < ActiveRecord::Base
  self.table_name = "spree_substitution_probabilities"
  def self.generate_probabilities
        substitutions = SubstitutionCount.find(:all)
        substitutions.each do |substitution|
          product_searched_and_out_of_stock = UserBehavior.number_of_times_searched_and_out_of_stock(substitution.searched_product)
          next if product_searched_and_out_of_stock == 0
          probability = substitution.count / product_searched_and_out_of_stock.to_f
          create_or_update_probability(substitution.searched_product, substitution.bought_product, probability)
          Rails.logger.info "Substitution probability of #{substitution.searched_product} with #{substitution.bought_product} is #{probability}"
        end
  end

  def self.create_or_update_probability(searched, bought, probability)
        substitution = SubstitutionProbability.find_or_create_by_searched_product_and_bought_product(searched, bought)
        substitution.probability = probability
        substitution.save
  end
end
