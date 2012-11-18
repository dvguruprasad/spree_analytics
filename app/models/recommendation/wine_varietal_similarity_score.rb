module Recommendation
    class WineVarietalSimilarityScore < ActiveRecord::Base
        def self.for(wine1, wine2)
            return 0.01 if wine1.wine_type != wine2.wine_type
            return 1 if wine1.varietal == wine2.varietal
            conditions=<<-SQL
                  "((wine_variety_1 = ? and wine_variety_2 = ?) or (wine_variety_1 = ? and wine_variety_2 = ?)) and wine_type = ?"
            SQL
            record = find(:first, :conditions => [conditions, wine1.varietal, wine2.varietal, wine2.varietal, wine1.varietal, wine1.wine_type])
            record.nil? ? 0.01 : record.similarity_score
        end
    end
end
