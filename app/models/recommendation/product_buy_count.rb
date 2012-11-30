module Recommendation
    class ProductBuyCount < ActiveRecord::Base
        self.table_name = "spree_product_buy_counts"

        def self.last_capture_timestamp
            CFRecommendationIdentificationTimestamp.read_and_update
        end

        def self.generate()
            all_users = Spree.user_class.all
            last_capture_timestamp = self.last_capture_timestamp
            all_users.each do |u|
                user_purchases = UserBehavior.all_purchase_behavior_since(u.id, last_capture_timestamp)
                next if user_purchases.empty?
                buy_count = Hash.new(0)
                user_purchases.each do |purchase|
                    product_ids = purchase.products
                    product_ids.each do |p|
                        buy_count[p] += 1
                    end
                end
                buy_count.each do |product_id,count|
                    save_product_buy_count(u.id,product_id,count)
                end

            end
        end

        def self.save_product_buy_count(user_id, product_id, count)
            product_buy_count = ProductBuyCount.find_by_user_id_and_product_id(user_id, product_id)
            if product_buy_count.nil?
                product_buy_count = ProductBuyCount.new()
                product_buy_count.user_id = user_id
                product_buy_count.product_id = product_id
                product_buy_count.count = count
                product_buy_count.save
            else
                product_buy_count.count += count
                product_buy_count.save
            end

        end
    end
end
