module Recommendation
    class UserSimilarityScore < ActiveRecord::Base
        self.table_name = "spree_user_similarity_scores" 
        attr_accessible :user1_id, :user2_id, :score

        def self.create_scores
            all_users = Spree.user_class.find_all_with_atleast_one_purchase
            return if all_users.count < 2
            for i in 0..all_users.count-1
                for j in (i+1)..all_users.count-1
                    user_similarity_score = self.similarity_score(all_users[i], all_users[j])
                    self.create_or_update(all_users[i].id, all_users[j].id, user_similarity_score) unless user_similarity_score == 0
                end
            end
        end

        def self.similarity_score(user_1, user_2)
            common_product_ids = user_1.common_products(user_2)
            return 0 if common_product_ids.empty?
            user_1_products = user_1.product_buy_counts
            user_2_products = user_2.product_buy_counts

            buy_count_1 = {}
            buy_count_2 = {}

            user_1_products.each {|pbc| buy_count_1[pbc.product_id] = pbc.count}
            user_2_products.each {|pbc| buy_count_2[pbc.product_id] = pbc.count}

            pearson_similarity_score(common_product_ids, buy_count_1, buy_count_2) 
        end

        def self.pearson_similarity_score(common_products, buy_count_1, buy_count_2)
            vector_1 = []
            vector_2 = []
            common_products.each do |product|
                vector_1 << buy_count_1[product]
                vector_2 << buy_count_2[product]
            end
            PearsonCoefficient.compute(vector_1, vector_2)
        end

        def self.similar_to(user_id)
            similar_users = {}
            user1_match_scores = UserSimilarityScore.find_all_by_user1_id(user_id)
            user2_match_scores = UserSimilarityScore.find_all_by_user2_id(user_id)

            user1_match_scores.each {|usc| similar_users[Spree.user_class.find(usc.user2_id)] = usc.score}
            user2_match_scores.each {|usc| similar_users[Spree.user_class.find(usc.user1_id)] = usc.score}
            similar_users
        end
        private

        def self.create_or_update(user1, user2, score)
            user_similarity_score = UserSimilarityScore.find_by_user1_id_and_user2_id(user1,user2)
            if user_similarity_score.nil?
                UserSimilarityScore.create(:user1_id => user1, :user2_id => user2, :score => score) 
            else
                user_similarity_score.score = score
                user_similarity_score.save
            end
        end
    end
end
