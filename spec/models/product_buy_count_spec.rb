require 'spec_helper'

class ProductBuyCountSpec
    describe "ProductBuyCount" do
        context ".generate product buy count (one user scenario)" do
            it "should not create product buy count if there are no purchases" do
                user = FactoryGirl.create(:user)
                create_search_behavior(1111,true, user.id)
                ProductBuyCount.generate()
                ProductBuyCount.count().should eql(0)
            end

            it "should create only one product buy count when there is one purchase" do
                user = FactoryGirl.create(:user)
                create_search_and_purchase_behavior(1111, 1, user.id)
                ProductBuyCount.generate()
                ProductBuyCount.count().should eql(1)
                product_buy_count = ProductBuyCount.find(:first)
                product_buy_count.product_id.should eql(1111)
                product_buy_count.user_id.should eql(user.id)
                product_buy_count.count.should eql(1)
            end

            it "should create product buy counts when there are many purchases of a single product" do
                user = FactoryGirl.create(:user)
                create_search_and_purchase_behavior(1111, 3, user.id)
                ProductBuyCount.generate()
                ProductBuyCount.count().should eql(1)
                product_buy_count = ProductBuyCount.find(:first)
                product_buy_count.product_id.should eql(1111)
                product_buy_count.user_id.should eql(user.id)
                product_buy_count.count.should eql(3)
            end


        end

        private
        def create_search_and_purchase_behavior(product_id,number_of_behaviors,user_id)
            number_of_behaviors.times do |index|
                create_search_behavior(product_id,true, user_id)
                create_purchase_behavior(product_id,index + rand() , user_id)
            end
        end
        def create_search_behavior(product, is_available, user)
            FactoryGirl.create(:search_behavior, product: product, is_available: is_available, user_id: user)
        end

        def create_purchase_behavior(product, order, user)
            FactoryGirl.create(:purchase_behavior, :parameters => "{\"products\": [#{product}], \"order\": #{order} }", :user_id => user)
        end
    end
end
