module Recommendation
    class WineTypeSimilarityScore < ActiveRecord::Base
        def self.for(wine_type_1, wine_type_2)
            return 1 if wine_type_1 == wine_type_2
            record = WineTypeSimilarityScore.find(:all, :conditions => ["(wine_type_1=? and wine_type_2=?) or (wine_type_2=? and wine_type_1=?)", wine_type_1, wine_type_2, wine_type_2, wine_type_1]).first
            return record.nil? ? 0 : record.similarity_score
        end
    end
end
