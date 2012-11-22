class ProductBuyCount < ActiveRecord::Base
    self.table_name = "spree_product_buy_counts"

    def self.generate()
        all_users = Spree.user_class.all
        all_users.each do |u|
            user_purchases = UserBehavior.find_all_by_user_id_and_action(u.id,"P")
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
        product_buy_count = ProductBuyCount.new()
        product_buy_count.user_id = user_id
        product_buy_count.product_id = product_id
        product_buy_count.count = count
        product_buy_count.save
    end
end
