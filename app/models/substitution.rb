class Substitution < ActiveRecord::Base
    self.table_name = "spree_substitution_counts"

    def self.capture
        all_users = Spree.user_class.find(:all, :select => :id)
        timestamp = self.last_capture_timestamp
        all_users.each do |user|
            substitutions = user.substitutions_since(timestamp, self)
            substitutions.each do |substitution|
                p "#{substitution.count} #{self} found between: #{substitution.searched_product} and #{substitution.bought_product}"
                substitution = substitution.create_or_update_substitution
            end
        end
    end

    def self.substitution(searched_product, bought_product)
        substitution = self.new
        substitution.searched_product = searched_product
        substitution.bought_product = bought_product
        substitution
    end

    def self.category(product_id)
        Spree::Product.find_by_id(product_id).category_taxon
    end

    def self.products_grouped_by_category(products)
        result = {}
        raise "NoProductsInPurchaseBehavior" if products.nil?
        products.each do |p|
            c = category(p)
            result[c] ||= []
            result[c] << p
        end
        result
    end

    def create_or_update_substitution
        substitution = self.class.find_or_create_by_searched_product_and_bought_product(searched_product,bought_product)
        substitution.count=0 if substitution.count.nil?
        substitution.count += 1
        substitution.save
        substitution
    end


    def eql?(other)
        searched_product == other.searched_product && bought_product == other.bought_product
    end
end
