module Recommendation
    class Wine
        @@body_hash = {"A - Light" => 0, "B - Medium Light" => 1, "C - Medium" => 2, "D - Medium Full" => 3, "E - Full" => 4, }

        def initialize(product)
            @product = product
        end

        def wine_type
            @product.property("wine_type")
        end

        def body
            @@body_hash[@product.property("wine_body")]
        end

        def sweetness
            @product.property("wine_sweetness")
        end

        def vintage
            @product.property("wine_vintage").to_i
        end

        def varietal
            @product.property("wine_varietal").to_i
        end

        def name
            @product.name
        end

        def deleted?
            @product.deleted?
        end

        def images
            @product.images
        end

        def self.all_with_sweetness(sweetness)
            query_for_wines_with_same_sweetness = <<-SQL
            select prod.* from spree_products prod inner join spree_product_properties pp on pp.product_id = prod.id 
                    inner join spree_properties prop on prop.id = pp.property_id where prop.name = :property_name and pp.value = :property_value
            SQL
            all_wines = Spree::Product.find_by_sql([query_for_wines_with_same_sweetness, {:property_name => "wine_sweetness", :property_value => sweetness}])
            all_wines.map{|product| Wine.new(product)}
        end
    end
end
