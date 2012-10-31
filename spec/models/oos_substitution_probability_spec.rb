require 'spec_helper'

class OOSSubstitutionProbabilitySpec
    describe "OOSSubstitutionProbability" do
        @@searched = 12345
        @@purchased = 54321

        context ".generate_proabilities" do
            it "should find substitution probability of a product given substitution count" do
                create_behaviors(@@searched, @@purchased, 5, 2)
                substitution = Factory.create(:oos_substitution, searched_product: @@searched, bought_product: @@purchased, count: 5)
                OOSSubstitutionProbability.generate_probabilities
                substitution_probabilities = OOSSubstitutionProbability.find(:all)
                substitution_probabilities.count.should eql 1
                substitution_probabilities.first.searched_product.should eql @@searched
                substitution_probabilities.first.bought_product.should eql @@purchased
                substitution_probabilities.first.probability.should eql 5.0/7.0

            end

            it "should generate substitution probabilities for all substituted products" do
                searched_2, purchased_2 = 11111, 22222
                searched_3, purchased_3 = 77777, 88888
                create_behaviors(@@searched, @@purchased, 5, 2)
                Factory.create(:oos_substitution, searched_product: @@searched, bought_product: @@purchased, count: 5)
                create_behaviors(searched_2, purchased_2, 3, 4)
                Factory.create(:oos_substitution, searched_product: searched_2, bought_product: purchased_2, count: 3)
                create_behaviors(searched_3, purchased_3, 6, 3)
                Factory.create(:oos_substitution, searched_product: searched_3, bought_product: purchased_3, count: 6)

                OOSSubstitutionProbability.generate_probabilities
                substitution_probabilities = OOSSubstitutionProbability.find(:all)
                substitution_probabilities.count eql 3
                assert_probabilities(substitution_probabilities, @@searched, @@purchased, 0.7142857142857143)
                assert_probabilities(substitution_probabilities, searched_2, purchased_2, 0.42857142857142855)
                assert_probabilities(substitution_probabilities, searched_3, purchased_3, 0.6666666666666666)

            end

        end

        private
        def create_behaviors(searched_product, purchased_product, number_of_substitutions, number_of_searches_when_out_of_stock)
            number_of_substitutions.times do
                create_search_behavior(searched_product, false,1)
                create_purchase_behavior(purchased_product,999,1)
            end
            number_of_searches_when_out_of_stock.times do
                create_search_behavior(searched_product, false,1)
            end
        end

        def create_search_behavior(product, is_available, user)
            FactoryGirl.create(:search_behavior, product: product, is_available: is_available, user_id: user)
        end

        def create_purchase_behavior(product, order, user)
            FactoryGirl.create(:purchase_behavior, :parameters => "{\"product\": #{product}, \"order\": #{order} }", :user_id => user)
        end

        def assert_probabilities(actual_probabilities, searched, purchased, probability)
            actual_probabilities.any? do |p|
                p.bought_product == purchased && p.searched_product == searched && p.probability == probability
            end.should be_true
        end
    end
end
