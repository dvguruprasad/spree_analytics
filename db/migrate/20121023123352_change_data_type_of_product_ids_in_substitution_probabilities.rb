class ChangeDataTypeOfProductIdsInSubstitutionProbabilities < ActiveRecord::Migration
  def change
      change_column :spree_substitution_probabilities, :searched_product ,:integer
      change_column :spree_substitution_probabilities, :bought_product ,:integer
  end
end
