class CreateWineTypeSimilarityScoresTable < ActiveRecord::Migration
    def change
        create_table(:wine_type_similarity_scores) do |t|
            t.string :wine_type_1
            t.string :wine_type_2
            t.float :similarity_score
            t.timestamps
        end
    end
end
