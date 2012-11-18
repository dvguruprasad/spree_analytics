module Recommendation
    class AttributeBasedSimilarity
        WINE_TYPE_WEIGHT = 50
        VARIETAL_WEIGHT = 40
        BODY_WEIGHT = 30
        VINTAGE_WEIGHT = 20

        # this works only for wines!
        def self.similar_to(product)
            return [] if product.category_taxon.first.name != WINE_TAXON
            wine = Wine.new(product)
            all_wines = Wine.all_with_sweetness(wine.sweetness)
            similarity_scores = {}
            all_wines.each do |w|
                next if w.name == wine.name || w.deleted?
                similarity_scores[w] = similarity_score(wine, w)
            end
            sorted = similarity_scores.sort_by{|key, value| value}.reverse
            sorted.map{|value| value[0]}.take(6)
        end

        private
        def self.similarity_score(wine1, wine2)
            wine_type_similarity = WineTypeSimilarityScore.for(wine1, wine2)
            varietal_similarity = WineVarietalSimilarityScore.for(wine1, wine2)
            body_similarity = similarity_between_numerals(wine1.body, wine2.body, 5.0)
            vintage_similarity = vintage_similarity(wine1.vintage, wine2.vintage)
            wine_type_similarity * WINE_TYPE_WEIGHT + varietal_similarity * VARIETAL_WEIGHT
                                        + body_similarity * BODY_WEIGHT + vintage_similarity * VINTAGE_WEIGHT
        end

        def self.vintage_similarity(vintage_1, vintage_2)
            return 0 if(vintage_1 == 0 or vintage_2 == 0)
            similarity_between_numerals(vintage_1, vintage_2, 300.0)
        end

        def self.similarity_between_numerals(numeral_1, numeral_2, total_number)
            (total_number - (numeral_1 - numeral_2).abs) / total_number
        end
    end
end
