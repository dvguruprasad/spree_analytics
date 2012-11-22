require 'spec_helper'

class ProductBuyCountSpec
    describe "ProductBuyCount" do
        context ".generate" do
            it "should not create product buy count if there are no purchases" do
                user = FactoryGirl.create(:user)
                create_search_behavior(1111,true, user.id)
                ProductBuyCount.generate()
                ProductBuyCount.count().should eql(0)
            end

            it "should create only one product buy count when there is one purchase" do
                user = FactoryGirl.create(:user)
                create_search_behavior(1111,true, user.id)
                create_purchase_behavior(1111,007, user.id)
                ProductBuyCount.generate()
                ProductBuyCount.count().should eql(1)
                product_buy_count = ProductBuyCount.find(:first)
                product_buy_count.product_id.should eql(1111)
                product_buy_count.user_id.should eql(user.id)
                product_buy_count.count.should eql(1)
            end

        end

        private
        def create_search_behavior(product, is_available, user)
            FactoryGirl.create(:search_behavior, product: product, is_available: is_available, user_id: user)
        end

        def create_purchase_behavior(product, order, user)
            FactoryGirl.create(:purchase_behavior, :parameters => "{\"products\": [#{product}], \"order\": #{order} }", :user_id => user)
        end
    end
end
