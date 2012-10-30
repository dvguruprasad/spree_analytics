class AddTypeToSubstitutionCounts < ActiveRecord::Migration
  def change
      add_column :spree_substitution_counts, :type, :string
  end
end
