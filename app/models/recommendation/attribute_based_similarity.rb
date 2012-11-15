module Recommendation
    class AttributeBasedSimilarity
        @@body_hash = {"A - Light" => 0, "B - Medium Light" => 1, "C - Medium" => 2, "D - Medium Full" => 3, "E - Full" => 4, }

        WINE_TYPE_WEIGHT = 40
        BODY_WEIGHT = 30
        VINTAGE_WEIGHT = 20
        VARIETAL_WEIGHT = 10

        WINE_SWEETNESS_PROPERTY = "wine_sweetness"

        # this works only for wines!
        def self.similar_to(product)
            return [] if product.category_taxon.first.name != WINE_TAXON
            all_wines = query_by_sweetness(product.property(WINE_SWEETNESS_PROPERTY))
            similarity_scores = {}
            all_wines.each do |w|
                next if w.name == product.name || w.deleted?
                similarity_scores[w] = similarity_score(product, w)
            end
            sorted = similarity_scores.sort_by{|key, value| value}.reverse
            sorted.map{|value| value[0]}.take(6)
        end

        private
        def self.query_by_sweetness(sweetness)
            query_for_wines_with_same_sweetness = <<-SQL
            select prod.* from spree_products prod inner join spree_product_properties pp on pp.product_id = prod.id 
                    inner join spree_properties prop on prop.id = pp.property_id where prop.name = :property_name and pp.value = :property_value
            SQL
            all_wines = Spree::Product.find_by_sql([query_for_wines_with_same_sweetness, {:property_name => WINE_SWEETNESS_PROPERTY, :property_value => sweetness}])
        end

        def self.similarity_score(wine1, wine2)
            wine_type_similarity = Recommendation::WineTypeSimilarityScore.for(wine_type(wine1), wine_type(wine2))
            body_similarity = similarity_between_numerals(wine_body(wine1), wine_body(wine2), 5.0)
            vintage_similarity = vintage_similarity(wine_vintage(wine1), wine_vintage(wine2))
            wine_type_similarity * WINE_TYPE_WEIGHT + body_similarity * BODY_WEIGHT + vintage_similarity * VINTAGE_WEIGHT
        end

        def self.similarity_between_numerals(numeral_1, numeral_2, total_number)
            (total_number - (numeral_1 - numeral_2).abs) / total_number
        end

        def self.vintage_similarity(vintage_1, vintage_2)
            return 0 if(vintage_1 == 0 or vintage_2 == 0)
            similarity_between_numerals(vintage_1, vintage_2, 300.0)
        end

        def self.wine_type(wine)
            wine.property("wine_type")
        end

        def self.wine_body(wine)
            @@body_hash[wine.property("wine_body")]
        end

        def self.wine_vintage(wine)
            wine.property("wine_vintage").to_i
        end
    end
end
