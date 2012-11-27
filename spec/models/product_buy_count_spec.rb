require 'spec_helper'
module Recommendation
    class ProductBuyCountSpec
        describe "ProductBuyCount" do

            context ".generate product buy count (no user scenario)" do
                it "should not create product buy count if there are no users" do
                    ProductBuyCount.generate()
                    ProductBuyCount.count().should eql(0)
                end
            end

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
                    assert_product_buy_count(product_buy_count,1111,user.id,1)
                end

                it "should create product buy counts when there are many purchases of a single product" do
                    user = FactoryGirl.create(:user)
                    create_search_and_purchase_behavior(1111, 3, user.id)
                    ProductBuyCount.generate()
                    ProductBuyCount.count().should eql(1)
                    product_buy_count = ProductBuyCount.find(:first)
                    assert_product_buy_count(product_buy_count,1111,user.id,3)
                end

                it "should create product buy counts when there are many purchases across products" do
                    user = FactoryGirl.create(:user)
                    create_search_and_purchase_behavior(1111, 3, user.id)
                    create_search_and_purchase_behavior(2222, 2, user.id)
                    ProductBuyCount.generate()
                    ProductBuyCount.count().should eql(2)
                    product_buy_count = ProductBuyCount.find(:all)
                    assert_product_buy_count(product_buy_count[0], 1111, user.id, 3)
                    assert_product_buy_count(product_buy_count[1], 2222, user.id, 2)
                end


            end

            context ".generate product buy count (multiple user scenario)" do
                it "should not create product buy count if there are no purchases" do
                    user1 = FactoryGirl.create(:user)
                    user2 = FactoryGirl.create(:user)
                    create_search_behavior(1111,true, user1.id)
                    create_search_behavior(1122,true, user2.id)
                    ProductBuyCount.generate()
                    ProductBuyCount.count().should eql(0)
                end

                it "should not create product buy count for the users with no behaviors" do
                    user1 = FactoryGirl.create(:user)
                    user2 = FactoryGirl.create(:user)
                    create_search_and_purchase_behavior(1111, 1, user1.id)
                    ProductBuyCount.generate()
                    ProductBuyCount.count().should eql(1)
                    product_buy_count = ProductBuyCount.find(:first)
                    assert_product_buy_count(product_buy_count, 1111, user1.id, 1)
                end

                it "should create product buy count if a single product is purchased by many users" do
                    user1 = FactoryGirl.create(:user)
                    user2 = FactoryGirl.create(:user)
                    create_search_and_purchase_behavior(1111, 1, user1.id)
                    create_search_and_purchase_behavior(1111, 1, user2.id)
                    ProductBuyCount.generate()
                    ProductBuyCount.count().should eql(2)
                    product_buy_count = ProductBuyCount.find(:all)
                    assert_product_buy_count(product_buy_count[0], 1111, user1.id, 1)
                    assert_product_buy_count(product_buy_count[1], 1111, user2.id, 1)
                end

                it "should create product buy count if mutiple products are purchased by many users" do
                    user1 = FactoryGirl.create(:user)
                    user2 = FactoryGirl.create(:user)

                    create_search_and_purchase_behavior(1111, 2, user1.id)
                    create_search_and_purchase_behavior(2222, 3, user1.id)

                    create_search_and_purchase_behavior(1111, 1, user2.id)
                    create_search_and_purchase_behavior(3333, 2, user2.id)
                    ProductBuyCount.generate()
                    ProductBuyCount.count().should eql(4)
                    product_buy_count = ProductBuyCount.find(:all)
                    assert_product_buy_count(product_buy_count[0], 1111, user1.id, 2)
                    assert_product_buy_count(product_buy_count[1], 2222, user1.id, 3)
                    assert_product_buy_count(product_buy_count[2], 1111, user2.id, 1)
                    assert_product_buy_count(product_buy_count[3], 3333, user2.id, 2)
                end



            end

            private
            def assert_product_buy_count(product_buy_count, product_id, user_id, purchase_count)
                product_buy_count.product_id.should eql(product_id)
                product_buy_count.user_id.should eql(user_id)
                product_buy_count.count.should eql(purchase_count)

            end
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
end
