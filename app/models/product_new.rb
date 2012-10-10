class ProductNew
    class << self
        def  products_sold_for_price_range(range)
            query = <<-HERE
        select spree_products.name, spree_products.id , count(*) as product_count 
        from spree_products join spree_variants on (spree_products.id = spree_variants.product_id ) 
                            join spree_line_items on (spree_line_items.variant_id=spree_variants.id) 
                                and spree_variants.price >=#{range.first} and spree_variants.price <= #{range.last} 
                group by spree_products.id order by product_count desc 
            HERE
            product_names_with_count = ActiveRecord::Base.connection.select_all(query)
            data = in_percentage(product_names_with_count.map {|val|  val["product_count"]  })
            product_names = product_names_with_count.map {|val|  val["name"]  }
            {:product_names =>  product_names, :data => data}
        end

        def in_percentage values
            count = values.count
            sum = values.inject(:+)
            values.map{|value|  ((value/sum.to_f) *100).round(2)  }
        end
    end
end
