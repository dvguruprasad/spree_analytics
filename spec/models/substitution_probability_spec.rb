require 'spec_helper'

class SubstitutionProbabilitySpec
    describe "SubstitutionProbability" do
        context "#generate_proabilities" do
            it "should find substitution probability of a product given substitution count" do
                create_search_behavior(12345,false,1)
                create_search_behavior(12345,false,1)
                create_purchase_behavior(54321,999,1)
                create_search_behavior(12345,false,1)
                create_purchase_behavior(54321,999,1)
                create_search_behavior(12345,false,1)
                create_purchase_behavior(54321,999,1)
                create_search_behavior(12345,false,1)
                create_purchase_behavior(54321,999,1)
                create_search_behavior(12345,false,1)
                create_purchase_behavior(54321,999,1)
                create_search_behavior(12345,false,1)
                substitution_count = Factory.create(:substitution, searched_product: 12345, bought_product: 54321, count: 5)
                SubstitutionProbability.generate_probabilities
                substitution_probabilities = SubstitutionProbability.find(:all)
                substitution_probabilities.count eql 1
                substitution_probabilities.first.searched_product.should eql 12345
                substitution_probabilities.first.bought_product.should eql 54321
                substitution_probabilities.first.probability.should eql 5.0/7.0

            end
        end

        private
        def create_search_behavior(product, is_available, user)
            FactoryGirl.create(:search_behavior, :parameters => "{\"product\": #{product}, \"available\": #{is_available} }", :user_id => user)
        end

        def create_purchase_behavior(product, order, user)
            FactoryGirl.create(:purchase_behavior, :parameters => "{\"product\": #{product}, \"order\": #{order} }", :user_id => user)
        end

    end
end
