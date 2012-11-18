module Recommendation
    class WineTypeSimilarityScore < ActiveRecord::Base
        def self.for(wine1, wine2)
            return 1 if wine1.wine_type == wine2.wine_type
            conditions = <<-SQL
                "(wine_type_1=? and wine_type_2=?) or (wine_type_2=? and wine_type_1=?)"
            SQL
            record = WineTypeSimilarityScore.find(:first, :conditions => [conditions, wine1.wine_type, wine2.wine_type, wine2.wine_type, wine1.wine_type])
            record.nil? ? 0.01 : record.similarity_score
        end
    end
end
