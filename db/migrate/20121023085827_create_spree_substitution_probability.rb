class CreateSpreeSubstitutionProbability < ActiveRecord::Migration
  def change
    create_table :spree_substitution_probability, :force => true do |t|
      t.string   :searched_product
      t.string   :bought_product
      t.float    :probability
      t.timestamps
    end
  end
end
