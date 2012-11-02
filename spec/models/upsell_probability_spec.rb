require 'spec_helper'

class UpsellProbabilitySpec
    describe "Upsell" do
        context ".generate_probabilities" do
            it "should generate upsell probabilities" do
                FactoryGirl.create(:upsell,  searched_product: 1, bought_product: 2, count: 5)
                create_searches(product = 1, count = 8)
                SubstitutionProbability.generate_for_upsell
                probabilities = UpsellProbability.find(:all)
                probabilities.count.should eql 1
                probabilities.first.searched_product.should eql 1
                probabilities.first.bought_product.should eql 2
                probabilities.first.probability.should eql 5/8.0
            end

            it "should generate upsell probabilities for all upsells" do
                FactoryGirl.create(:upsell,  searched_product: 1, bought_product: 2, count: 5)
                create_searches(product = 1, count = 8)

                FactoryGirl.create(:upsell,  searched_product: 3, bought_product: 4, count: 8)
                create_searches(product = 3, count = 16)
                SubstitutionProbability.generate_for_upsell

                probabilities = UpsellProbability.find(:all)
                probabilities.count.should eql 2

                probabilities.first.searched_product.should eql 1
                probabilities.first.bought_product.should eql 2
                probabilities.first.probability.should eql 5/8.0

                probabilities.last.searched_product.should eql 3
                probabilities.last.bought_product.should eql 4
                probabilities.last.probability.should eql 8/16.0
            end
        end

        private
        def create_searches(product, count)
            count.times do
                FactoryGirl.create(:search_behavior, product: product)
            end
        end
    end
end
