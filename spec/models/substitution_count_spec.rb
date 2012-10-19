require 'spec_helper'

class SubstitutionCountSpec
    describe "SubstitutionCount" do
        context "#eql?" do
            it "should be able to find if two SubstituionCounts are equal" do
                substitution_1 = Factory.create(:substitution, searched_product: 12345, bought_product: 54321, count: 5)
                substitution_2 = Factory.create(:substitution, searched_product: 12345, bought_product: 54321, count: 3)
                substitution_1.should eql(substitution_2)
            end
        end
    end
end
