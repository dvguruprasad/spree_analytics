Spree::Product.instance_eval do
    def  products_sold_for_price_range(range)
        query = <<-HERE
        select spree_products.name as product_name, spree_products.id , count(*) as product_count
        from spree_products join spree_variants on (spree_products.id = spree_variants.product_id )
                            join spree_line_items on (spree_line_items.variant_id=spree_variants.id)
                                and spree_variants.price >=#{range.first} and spree_variants.price < #{range.last}
                group by spree_products.id order by product_count desc
                                HERE
                                construct_result(query)
    end

    def products_sold_in_date_range(range)
        from = Date.today - range.end
        to = Date.today - range.begin
        query = <<-HERE
                select p.name as product_name, count(*) as product_count
                from spree_orders o join spree_line_items li on(o.id=li.order_id)
                                    join spree_variants v on(li.variant_id=v.id)
                                    join spree_products p on p.id = v.product_id
                where o.created_at >= '#{from}' and o.created_at < '#{to}' group by p.id
        HERE
        construct_result(query)
    end

    def products_by_transaction_frequency(range)
        query = <<-HERE
                select p.name as product_name, count(*) as product_count
                from spree_orders o join spree_line_items li on(o.id=li.order_id)
                                    join spree_variants v on(li.variant_id=v.id)
                                    join spree_products p on p.id = v.product_id
                group by p.id having product_count > #{range.begin}  and product_count <#{range.end}
                HERE
                construct_result(query)
    end

    private
    def construct_result(query)
        product_names_with_count = ActiveRecord::Base.connection.select_all(query)
        data = in_percentage(product_names_with_count.map {|val|  val["product_count"]  })
        product_names = product_names_with_count.map {|val|  val["product_name"]  }
        {:product_names =>  product_names, :data => data}
    end

    def in_percentage values
        count = values.count
        sum = values.inject(:+)
        values.map{|value|  ((value/sum.to_f) *100).round(2)  }
    end
end


Spree::Product.class_eval do
    CATEGORIES_TAXONOMY_NAME = "Categories"

    def out_of_stock?
        count_on_hand == 0
    end

    def category_taxon
        taxons.select {|t| t.taxonomy.name == CATEGORIES_TAXONOMY_NAME}
    end
end
