module Recommendation
    class ProductViewCount < ActiveRecord::Base
        self.table_name = "spree_product_view_counts"

        def self.last_capture_timestamp
            CFRecommendationIdentificationTimestamp.read_and_update
        end


        def self.generate()
            all_users = Spree.user_class.all
            last_capture_timestamp = self.last_capture_timestamp
            all_users.each do |u|
                user_searchs = UserBehavior.all_search_behavior_since(u.id, last_capture_timestamp)
                next if user_searches.empty?
                view_count = Hash.new(0)
                user_searches.each do |search|
                    view_count[search.product] += 1
                end
                view_count.each do |product_id,count|
                    save_product_view_count(u.id,product_id,count)
                end

            end
        end

        def self.save_product_view_count(user_id, product_id, count)
            product_view_count = ProductViewCount.find_by_user_id_and_product_id(user_id, product_id)
            if product_view_count.nil?
                product_view_count = ProductViewCount.new()
                product_view_count.user_id = user_id
                product_view_count.product_id = product_id
                product_view_count.count = count
                product_view_count.save
            else
                product_view_count.count += count
                product_view_count.save
            end

        end
    end
end

