Spree::Product.instance_eval do

    def  products_in_orders_with_monetary_range(range)
        products_bought_as_part_of_bucket = []
        users_in_bucket_range = [] 
        #Spree::Order.where("total >= #{range.first} and total < #{range.last}").map{|order| products_bought_as_part_of_bucket += order.products}
        Spree::User.order_values_by_users(Spree::User.all_users).each{|ovHash| users_in_bucket_range << ovHash[:user_id] if ovHash[:average_order_value] >= range.first and ovHash[:average_order_value] < range.last  }
        Spree::Order.where(:user_id => users_in_bucket_range).map{|order| products_bought_as_part_of_bucket += order.products}
        products_with_count = Hash.new(0)
        products_bought_as_part_of_bucket.each do |p|
            products_with_count[p] += 1
        end
        result = {:product_names => [], :data => []}
        products_with_count.map do |p,c| 
            result[:product_names] << p.name
        end
        result[:data] += in_percentage(products_with_count.values)
        result
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
    BRAND_TAXONOMY_NAME = "Brand"
    WINE_TAXON = "Wines"

    attr_accessor :is_promotional

    def is_promotional?
        !!@is_promotional
    end


    def out_of_stock?
        variants.empty? ? count_on_hand == 0 : variants.all?{|v| v.count_on_hand == 0}
    end

    def category_taxon
        taxons.select {|t| t.taxonomy.name == CATEGORIES_TAXONOMY_NAME}
    end

    def brand_taxon
        taxons.select {|t| t.taxonomy.name == BRAND_TAXONOMY_NAME}.first
    end

    def least_priced_variant
        variants.sort {|x, y| x.price <=> y.price}.first
    end

    def substitutes
        out_of_stock? ? OOSSubstitutionProbability.find_substitutes_for(self) : UpsellProbability.find_upsells_for(self)
    end

    # this works only for wines!
    def similar_products
        Recommendation::AttributeBasedSimilarity.similar_to(self)
    end

    def substitutions_enabled?
        !taxons.empty? && taxons.any? {|t| t.substitutions_enabled?}
    end

    def recommendations_enabled?
        !taxons.empty? && taxons.any? {|t| t.recommendations_enabled?}
    end
end
