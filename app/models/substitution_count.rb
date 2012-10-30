class SubstitutionCount < ActiveRecord::Base
    self.table_name = "spree_substitution_counts"

    def self.capture_out_of_stock_substitutions
        last_capture_timestamp = SubstitutionIdentificationTimestamp.read_and_update
        all_users = Spree.user_class.find(:all, :select => :id)
        all_users.each do |user|
            substitutions = user.substitutions_since(last_capture_timestamp)
            substitutions.each do |substitution|
                p "#{substitution.count} out of stock substitution found between: #{substitution.searched_product} and #{substitution.bought_product}"
                substitution = substitution.create_or_update_substitution
            end
        end
    end

    def self.capture_upsell_substitutions
        last_capture_timestamp = SubstitutionIdentificationTimestamp.read_and_update
        all_users = Spree.user_class.find(:all, :select => :id)
        all_users.each do |user|
            substitutions = user.substitutions_since(last_capture_timestamp)
            substitutions.each do |substitution|
                p "#{substitution.count} out of stock substitution found between: #{substitution.searched_product} and #{substitution.bought_product}"
                substitution = substitution.create_or_update_substitution
            end
        end
    end

    def create_or_update_substitution
        substitution = SubstitutionCount.find_or_create_by_searched_product_and_bought_product(searched_product,bought_product)
        substitution.count=0 if substitution.count.nil?
        substitution.count += 1
        substitution.save
        substitution
    end


    def eql?(other)
        searched_product == other.searched_product && bought_product == other.bought_product
    end
end
