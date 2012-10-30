class AddTypeToSubstitutionProbability < ActiveRecord::Migration
  def change
      add_column :spree_substitution_probabilities, :type, :string
  end
end
