require 'spec_helper'

class OOSSubstitutionCountSpec
    describe "OOSSubstitutionCount" do
        context "#eql?" do
            it "should be able to find if two SubstituionCounts are equal" do
                substitution_1 = Factory.create(:substitution, searched_product: 12345, bought_product: 54321, count: 5)
                substitution_2 = Factory.create(:substitution, searched_product: 12345, bought_product: 54321, count: 3)
                substitution_1.should eql(substitution_2)
            end
        end

        context ".capture_out_of_stock_substitutions" do
            before(:each) do
                @user_1 = double("user")
                @user_2 = double("user")
            end

            it "should capture the same substitution behavior across users" do
                substitutions_1 =  [substitution_count(11111, 22222, 1)]
                substitutions_2 =  [substitution_count(11111, 22222, 1)]

                Spree.user_class.should_receive(:find).with(:all, :select => :id).and_return([@user_1, @user_2])

                @user_1.should_receive(:substitutions_since).with(any_args()).and_return(substitutions_1)
                @user_2.should_receive(:substitutions_since).with(any_args()).and_return(substitutions_2)

                OOSSubstitutionCount.capture

                substitutions = OOSSubstitutionCount.find(:all)
                substitutions.count.should eql 1
                substitutions.first.count.should eq 2
                substitutions.first.searched_product.should eql 11111
                substitutions.first.bought_product.should eql 22222

            end

            it "should capture multiple substitutions across different users" do
                substitutions_1 =  [substitution_count(11111, 22222, 1)]
                substitutions_2 =  [substitution_count(33333, 44444, 1)]

                Spree.user_class.should_receive(:find).with(:all, :select => :id).and_return([@user_1, @user_2])

                @user_1.should_receive(:substitutions_since).with(any_args()).and_return(substitutions_1)
                @user_2.should_receive(:substitutions_since).with(any_args()).and_return(substitutions_2)

                OOSSubstitutionCount.capture

                substitutions = OOSSubstitutionCount.find(:all)
                substitutions.count.should eql 2
                substitutions.first.count.should eq 1
                substitutions.first.searched_product.should eql 11111
                substitutions.first.bought_product.should eql 22222

                substitutions.last.count.should eq 1
                substitutions.last.searched_product.should eql 33333
                substitutions.last.bought_product.should eql 44444
            end

            it "should capture multiple substitutions from the same user" do
                substitutions =  [substitution_count(11111, 22222, 1), substitution_count(33333, 44444, 1)]
                @user_1.should_receive(:substitutions_since).with(any_args()).and_return(substitutions)
                Spree.user_class.should_receive(:find).with(:all, :select => :id).and_return([@user_1])

                OOSSubstitutionCount.capture

                substitutions = OOSSubstitutionCount.find(:all)
                substitutions.count.should eql 2
                substitutions.first.count.should eq 1
                substitutions.first.searched_product.should eql 11111
                substitutions.first.bought_product.should eql 22222

                substitutions.last.count.should eq 1
                substitutions.last.searched_product.should eql 33333
                substitutions.last.bought_product.should eql 44444
            end


            def substitution_count(searched, bought, count)
                substitution_count = OOSSubstitutionCount.new
                substitution_count.searched_product= searched
                substitution_count.bought_product= bought
                substitution_count.count = count
                substitution_count
            end
        end

    end
end
