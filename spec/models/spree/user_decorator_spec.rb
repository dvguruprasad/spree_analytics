require File.dirname(__FILE__) + '/../../spec_helper'

class UserDecoratorSpec
    describe "User" do
        context "#substitutions_since" do
            before(:each) do
                @user = FactoryGirl.create(:user)
                categories_taxonomy = FactoryGirl.create(:taxonomy, :name => "Categories")
                @clothing_taxon = FactoryGirl.create(:taxon, :name => "Clothing", :taxonomy => categories_taxonomy)
                @deoderant_taxon = FactoryGirl.create(:taxon, :name => "Deoderant", :taxonomy => categories_taxonomy)
                @product_1 = FactoryGirl.create(:custom_product, :taxons => [@clothing_taxon])
                @product_2 = FactoryGirl.create(:custom_product, :taxons => [@deoderant_taxon])
            end

            it "should not return any substitutions when the only behavior is search" do
                create_search_behavior(product = 12345, is_available = true, @user.id)
                substitutions = @user.substitutions_since(DateTime.new(1970, 1, 1))
                substitutions.count.should eq 0
            end

            it "should not return any substitutions when the only behavior is search for a product that is out of stock" do
                create_search_behavior(product = 12345, is_available = false, @user.id)
                substitutions = @user.substitutions_since(DateTime.new(1970, 1, 1))
                substitutions.count.should eq 0
            end

            it "should not return any substitutions when the only behavior is a purchase" do
                substitutionCount = SubstitutionCount.new
                create_purchase_behavior(product = 12345, order = 111, @user.id)

                substitutions = @user.substitutions_since(DateTime.new(1970, 1, 1))
                substitutions.count.should eq 0
            end


            it "should not return any substitutions when the a product was searched for and purchased" do
                create_search_behavior(product = 99999, is_available = true, @user.id)
                create_add_to_cart_behavior(product = 99999, @user.id)
                create_purchase_behavior(product = 99999, order = 111, @user.id)

                substitutions = @user.substitutions_since(DateTime.new(1970, 1, 1))
                substitutions.count.should eql 0
            end

            it "should return a substitution when the a product was searched for and was not available and another was purchased" do
                product_3 = FactoryGirl.create(:custom_product, :taxons => [@clothing_taxon])
                create_search_behavior(product = @product_1.id, is_available = false, @user.id)
                create_search_behavior(product = product_3.id, is_available = true, @user.id)
                create_add_to_cart_behavior(product = product_3.id, @user.id)
                create_purchase_behavior(product = product_3.id, order = 111, @user.id)

                substitutions = @user.substitutions_since(DateTime.new(1970, 1, 1))
                substitutions.count.should eql 1
                substitutions.first.searched_product.should eql @product_1.id
                substitutions.first.bought_product.should eql product_3.id
                substitutions.first.count.should eql 1
            end

            it "should consider the last looked up out of stock product for substitution" do
                @product_3 = FactoryGirl.create(:custom_product, :taxons => [@deoderant_taxon])
                @product_4 = FactoryGirl.create(:custom_product, :taxons => [@deoderant_taxon])


                create_search_behavior(product = @product_1.id, is_available = false, @user.id)
                create_search_behavior(product = @product_3.id, is_available = false, @user.id)
                create_purchase_behavior(product = @product_2.id, order = 222, @user.id)
                create_purchase_behavior(product = @product_4.id, order = 444, @user.id)

                substitutions = @user.substitutions_since(DateTime.new(1970, 1, 1))
                substitutions.count.should eql 1
                substitutions.first.count.should eq 1
                substitutions.first.searched_product.should eql @product_3.id
                substitutions.first.bought_product.should eql @product_2.id
            end

            it "should not capture a substitution when the products belong to different categories" do
                categories_taxonomy = Factory.create(:taxonomy, :name => "Categories")
                product_1 = Factory.create(:custom_product, :taxons => [Factory.create(:taxon, :name => "cloth", :taxonomy => categories_taxonomy)])
                product_2 = Factory.create(:custom_product, :taxons => [Factory.create(:taxon, :name => "deodrant", :taxonomy => categories_taxonomy)])
                create_search_behavior(product = product_1.id, is_available = false, @user.id)
                create_search_behavior(product = product_2.id, is_available = true, @user.id)
                create_purchase_behavior(product = product_2.id, order = 222, @user.id)

                substitutions = @user.substitutions_since(DateTime.new(1970, 1, 1))
                substitutions.count.should eq 0
            end
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
