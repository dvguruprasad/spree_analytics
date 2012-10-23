class SubstitutionCount < ActiveRecord::Base
    self.table_name = "spree_substitution_counts"

    def create_or_update_substitution
        substitution = SubstitutionCount.find_or_create_by_searched_product_and_bought_product(searched_product,bought_product)
        substitution.count=0
        substitution.count += 1
        substitution.save
    end

    def eql?(other)
        searched_product == other.searched_product && bought_product == other.bought_product
    end
end
