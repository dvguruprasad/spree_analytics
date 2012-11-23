require 'spec_helper'

class UserSimilaritySpec
    describe "UserSimilarityScore" do
        context ".pearson_similarity_score" do 
            it "should return 0 if the common product buy count is 0" do
                user_1_buy_count = {1111 => 1, 2222 => 3, 3333 => 5}
                user_2_buy_count = {9999 => 1, 77777 => 3, 5555 => 5}
                common_products = []
                coeffiecient  = UserSimilarityScore.pearson_similarity_score(common_products, user_1_buy_count, user_2_buy_count)
                coeffiecient.should eql 0
            end

            it "should return 0 if there exists one common product with variance of one the product buy count is 0" do
                user_1_buy_count = {1111 => 1, 2222 => 3, 3333 => 5}
                user_2_buy_count = {1111 => 2, 9999 => 1, 77777 => 3, 5555 => 5}
                common_products = [1111]
                coeffiecient  = UserSimilarityScore.pearson_similarity_score(common_products, user_1_buy_count, user_2_buy_count)
                coeffiecient.should eql 0
            end

            it "should return 0 if there exists common product with their co-variance equal 0" do
                user_1_buy_count = {1111 => 1, 2222 => 3, 3333 => 5, 4444 => 2}
                user_2_buy_count = {1111 => 2, 9999 => 1, 77777 => 3, 5555 => 5, 4444 => 2}
                common_products = [1111, 4444]
                coeffiecient  = UserSimilarityScore.pearson_similarity_score(common_products, user_1_buy_count, user_2_buy_count)
                coeffiecient.should eql 0
            end

            it "should return similarity score if there exists common products" do
                user_1_buy_count = {1111 => 1, 2222 => 3, 3333 => 5, 4444 => 2, 9999 => 3}
                user_2_buy_count = {1111 => 2, 9999 => 1, 77777 => 3, 5555 => 5, 4444 => 2}
                common_products = [1111, 4444, 9999]
                coeffiecient  = UserSimilarityScore.pearson_similarity_score(common_products, user_1_buy_count, user_2_buy_count)
                coeffiecient.should eql -0.866025403784439
            end

        end
    end
end
