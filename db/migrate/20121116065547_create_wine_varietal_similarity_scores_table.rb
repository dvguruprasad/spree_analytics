class CreateWineVarietalSimilarityScoresTable < ActiveRecord::Migration
  def change
    create_table(:wine_varietal_similarity_scores) do |t|
      t.string :wine_variety_1
      t.string :wine_variety_2
      t.string :wine_type
      t.float :similarity_score
      t.timestamps
    end
  end
end
