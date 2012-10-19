require File.dirname(__FILE__) + '/../spec_helper'
require "#{File.dirname(__FILE__)}/../../lib/tasks/substitutions_captor"

class SubstitutionCaptorSpec
    describe "SubstitutionCaptor" do
        before(:each) do
            @user_1 = FactoryGirl.create(:user)
        end

        it "should not create any substitutions when the only behavior is search" do
            create_search_behavior(product = 12345, is_available = true, user = @user_1.id)
            SubstitutionsCaptor.capture

            SubstitutionCount.count.should eql 0
        end

        it "should not create any substitutions when the only behavior is search for a product that is out of stock" do
            create_search_behavior(product = 12345, is_available = false, user = @user_1.id)
            SubstitutionsCaptor.capture

            SubstitutionCount.count.should eql 0
        end

        it "should not create any substitutions when the only behavior is a purchase" do
            substitutionCount = SubstitutionCount.new
            create_purchase_behavior(product = 12345, order = 111, user = @user_1.id)

            SubstitutionsCaptor.capture
            SubstitutionCount.count.should eql 0
        end

        it "should create a substitution when the a product was searched for and was not available and another was purchased" do
            create_search_behavior(product = 12345, is_available = false, user = @user_1.id)
            create_search_behavior(product = 99999, is_available = true, user = @user_1.id)
            create_add_to_cart_behavior(product = 99999, user = @user_1.id)
            create_purchase_behavior(product = 99999, order = 111, user = @user_1.id)

            SubstitutionsCaptor.capture
            substitutions = SubstitutionCount.find(:all)
            substitutions.count.should eql 1
            substitutions.first.searched_product.should eql 12345
            substitutions.first.bought_product.should eql 99999
            substitutions.first.count.should eql 1

        end

        it "should not create a substitution when the a product was searched for and purchased" do
            create_search_behavior(product = 99999, is_available = true, user = @user_1.id)
            create_add_to_cart_behavior(product = 99999, user = @user_1.id)
            create_purchase_behavior(product = 99999, order = 111, user = @user_1.id)

            SubstitutionsCaptor.capture
            SubstitutionCount.count.should eql 0
        end

        it "should capture the same substitution behavior across users" do
            @user_2 = FactoryGirl.create(:user, :email => "foo@bar.com")
            create_search_behavior(product = 11111, is_available = false, user = @user_1.id)
            create_add_to_cart_behavior(product = 22222, user = @user_1.id)
            create_purchase_behavior(product = 22222, order = 111, user = @user_1.id)

            create_search_behavior(product = 11111, is_available = false, user = @user_2.id)
            create_add_to_cart_behavior(product = 22222, user = @user_2.id)
            create_purchase_behavior(product = 22222, order = 222, user = @user_2.id)

            SubstitutionsCaptor.capture

            substitutions = SubstitutionCount.find(:all)
            substitutions.count.should eql 1
            substitutions.first.count.should eq 2
            substitutions.first.searched_product.should eql 11111
            substitutions.first.bought_product.should eql 22222

        end

        it "should capture multiple substitutions across different users" do
            @user_2 = FactoryGirl.create(:user, :email => "foo@bar.com")
            create_search_behavior(product = 11111, is_available = false, user = @user_1.id)
            create_add_to_cart_behavior(product = 22222, user = @user_1.id)
            create_purchase_behavior(product = 22222, order = 111, user = @user_1.id)

            create_search_behavior(product = 33333, is_available = false, user = @user_2.id)
            create_add_to_cart_behavior(product = 44444, user = @user_2.id)
            create_purchase_behavior(product = 44444, order = 222, user = @user_2.id)

            SubstitutionsCaptor.capture

            substitutions = SubstitutionCount.find(:all)
            substitutions.count.should eql 2
            substitutions.first.count.should eq 1
            substitutions.first.searched_product.should eql 11111
            substitutions.first.bought_product.should eql 22222

            substitutions.last.count.should eq 1
            substitutions.last.searched_product.should eql 33333
            substitutions.last.bought_product.should eql 44444
        end

        it "should capture multiple substitutions from the same user" do
            create_search_behavior(product = 11111, is_available = false, user = @user_1.id)
            create_add_to_cart_behavior(product = 22222, user = @user_1.id)
            create_purchase_behavior(product = 22222, order = 111, user = @user_1.id)

            create_search_behavior(product = 33333, is_available = false, user = @user_1.id)
            create_add_to_cart_behavior(product = 44444, user = @user_1.id)
            create_purchase_behavior(product = 44444, order = 222, user = @user_1.id)

            SubstitutionsCaptor.capture

            substitutions = SubstitutionCount.find(:all)
            substitutions.count.should eql 2
            substitutions.first.count.should eq 1
            substitutions.first.searched_product.should eql 11111
            substitutions.first.bought_product.should eql 22222

            substitutions.last.count.should eq 1
            substitutions.last.searched_product.should eql 33333
            substitutions.last.bought_product.should eql 44444
        end

        it "should consider the last looked up out of stock product for substitution" do
            create_search_behavior(product = 11111, is_available = false, user = @user_1.id)

            create_search_behavior(product = 33333, is_available = false, user = @user_1.id)
            create_search_behavior(product = 44444, is_available = true, user = @user_1.id)
            create_add_to_cart_behavior(product = 44444, user = @user_1.id)
            create_purchase_behavior(product = 44444, order = 222, user = @user_1.id)

            create_search_behavior(product = 55555, is_available = true, user = @user_1.id)
            create_add_to_cart_behavior(product = 55555, user = @user_1.id)
            create_purchase_behavior(product = 55555, order = 222, user = @user_1.id)

            SubstitutionsCaptor.capture

            substitutions = SubstitutionCount.find(:all)
            substitutions.count.should eql 1
            substitutions.first.count.should eq 1
            substitutions.first.searched_product.should eql 33333
            substitutions.first.bought_product.should eql 44444
        end

        private
        def create_search_behavior(product, is_available, user)
            FactoryGirl.create(:search_behavior, :parameters => "{\"product\": #{product}, \"available\": #{is_available}}", :user_id => user)
        end

        def create_purchase_behavior(product, order, user)
            FactoryGirl.create(:purchase_behavior, :parameters => "{\"product\": #{product}, \"order\": #{order}}", :user_id => user)
        end

        def create_add_to_cart_behavior(product, user)
            FactoryGirl.create(:add_to_cart_behavior, :parameters => "{\"product\": #{product}}}", :user_id => user)
        end
    end
end
