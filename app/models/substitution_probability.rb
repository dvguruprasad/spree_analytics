class SubstitutionProbability < ActiveRecord::Base
  self.table_name = "spree_substitution_probability"
  def self.generate_probabilities
        substitutions = SubstitutionCount.find(:all)
        p "Generating Probabilities"
        substitutions.each do |substitution|
          product_searched_and_out_of_stock = UserBehavior.number_of_times_searched_and_out_of_stock(substitution.searched_product)
          probability_of_substitution = substitution.count.to_f/product_searched_and_out_of_stock.to_f if product_searched_and_out_of_stock != 0.0
          substitution_probability = SubstitutionProbability.new
          substitution_probability.searched_product = substitution.searched_product
          substitution_probability.bought_product = substitution.bought_product
          substitution_probability.probability = probability_of_substitution

          substitution_probability.create_or_update_substitution
          p "Substitution probability of #{substitution_probability.searched_product} with #{substitution_probability.bought_product} is #{substitution_probability.probability}"
        end
  end
  def create_or_update_substitution
        substitution = SubstitutionProbability.find_or_create_by_searched_product_and_bought_product(searched_product,bought_product)
        substitution.probability = probability
        substitution.save
  end

end
