class CreateSubstitutionCount < ActiveRecord::Migration
  def change
      create_table :spree_substitution_counts do |t|
          t.integer :searched_product
          t.integer :bought_product
          t.integer :count, :default => 0
          t.timestamps
      end
  end
end
