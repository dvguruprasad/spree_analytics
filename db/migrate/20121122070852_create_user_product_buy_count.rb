class CreateUserProductBuyCount < ActiveRecord::Migration
    def change
        create_table :spree_product_buy_counts ,:force => true do |t|
            t.integer :count
            t.integer :user_id
            t.integer :product_id
            t.timestamps
        end
    end
end
