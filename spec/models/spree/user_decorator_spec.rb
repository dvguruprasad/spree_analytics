require File.dirname(__FILE__) + '/../../spec_helper'

class UserDecoratorSpec
    describe "User" do
        context "#substitutions_since" do
            before(:each) do
                @user = FactoryGirl.create(:user)
                categories_taxonomy = FactoryGirl.create(:taxonomy, :name => "Categories")
                brands_taxonomy = FactoryGirl.create(:taxonomy, :name => "Brands")
                @clothing_taxon = FactoryGirl.create(:taxon, :name => "Clothing", :taxonomy => categories_taxonomy)
                @deoderant_taxon = FactoryGirl.create(:taxon, :name => "Deoderant", :taxonomy => categories_taxonomy)
                @reebok_brand = FactoryGirl.create(:taxon, :name => "Reebok", :taxonomy => brands_taxonomy)
                @nike_brand = FactoryGirl.create(:taxon, :name => "Nike", :taxonomy => brands_taxonomy)
                @product_1 = FactoryGirl.create(:custom_product, :taxons => [@clothing_taxon, @reebok_brand])
                @product_2 = FactoryGirl.create(:custom_product, :taxons => [@deoderant_taxon, @nike_brand])
            end

            it "should not return any substitutions when the only behavior is search" do
                create_search_behavior(product = 12345, is_available = true, @user.id)
                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eq 0
            end

            it "should not return any substitutions when the only behavior is search for a product that is out of stock" do
                create_search_behavior(product = 12345, is_available = false, @user.id)
                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eq 0
            end

            it "should not return any substitutions when the only behavior is a purchase" do
                substitutionCount = SubstitutionCount.new
                create_purchase_behavior(product = 12345, order = 111, @user.id)

                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eq 0
            end


            it "should not return any substitutions when the a product was searched for and purchased" do
                create_search_behavior(product = 99999, is_available = true, @user.id)
                create_add_to_cart_behavior(product = 99999, @user.id)
                create_purchase_behavior(product = 99999, order = 111, @user.id)

                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eql 0
            end

            it "should return a substitution when the a product was searched for and was not available and another was purchased" do
                product_3 = FactoryGirl.create(:custom_product, :taxons => [@clothing_taxon, @reebok_brand])
                create_search_behavior(product = @product_1.id, is_available = false, @user.id)
                create_search_behavior(product = product_3.id, is_available = true, @user.id)
                create_add_to_cart_behavior(product = product_3.id, @user.id)
                create_purchase_behavior(product = product_3.id, order = 111, @user.id)

                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eql 1
                substitutions.first.searched_product.should eql @product_1.id
                substitutions.first.bought_product.should eql product_3.id
                substitutions.first.count.should eql 1
            end

            it "should consider the last looked up out of stock product for substitution" do
                @product_3 = FactoryGirl.create(:custom_product, :taxons => [@deoderant_taxon, @nike_brand])
                @product_4 = FactoryGirl.create(:custom_product, :taxons => [@deoderant_taxon, @reebok_brand])


                create_search_behavior(product = @product_1.id, is_available = false, @user.id)
                create_search_behavior(product = @product_3.id, is_available = false, @user.id)
                create_purchase_behavior(product = @product_2.id, order = 222, @user.id)
                create_purchase_behavior(product = @product_4.id, order = 444, @user.id)

                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eql 1
                substitutions.first.count.should eq 1
                substitutions.first.searched_product.should eql @product_3.id
                substitutions.first.bought_product.should eql @product_2.id
            end

            it "should not capture a substitution when the products belong to different categories" do
                create_search_behavior(product = @product_1.id, is_available = false, @user.id)
                create_search_behavior(product = @product_2.id, is_available = true, @user.id)
                create_purchase_behavior(product = @product_2.id, order = 222, @user.id)

                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eq 0
            end

            it "should capture the substitution when the products belong to the same category and brand" do
                @product_2 = FactoryGirl.create(:custom_product, :taxons => [@reebok_brand, @clothing_taxon])
                create_search_behavior(product = @product_1.id, is_available = false, @user.id)
                create_search_behavior(product = @product_2.id, is_available = true, @user.id)
                create_purchase_behavior(product = @product_2.id, order = 222, @user.id)

                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eq 1
                substitutions.first.searched_product.should eql @product_1.id
                substitutions.first.bought_product.should eql @product_2.id
                substitutions.first.count.should eql 1
            end

            it "should capture the substitution when the products belong to the same category but a different brand" do
                @product_2 = FactoryGirl.create(:custom_product, :taxons => [@nike_brand, @clothing_taxon])
                create_search_behavior(product = @product_1.id, is_available = false, @user.id)
                create_search_behavior(product = @product_2.id, is_available = true, @user.id)
                create_purchase_behavior(product = @product_2.id, order = 222, @user.id)

                substitutions = @user.substitutions_since(epoch)
                substitutions.count.should eq 1
                substitutions.first.searched_product.should eql @product_1.id
                substitutions.first.bought_product.should eql @product_2.id
                substitutions.first.count.should eql 1
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

        def epoch
            DateTime.new(1970, 1, 1)
        end
    end
end
