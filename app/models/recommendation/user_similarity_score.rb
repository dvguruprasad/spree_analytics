module Recommendation
    class UserSimilarityScore < ActiveRecord::Base
        self.table_name = "spree_user_similarity_scores" 
        attr_accessible :user1_id, :user2_id, :score
        def self.create_scores
            query = <<-HERE
        select DISTINCT spree_users.* from spree_users RIGHT JOIN spree_product_buy_counts ON spree_users.id=spree_product_buy_counts.user_id;
            HERE
            all_users = Spree.user_class.find_by_sql(query)
            return if all_users.count < 2
            for i in 0..all_users.count-1
                for j in (i+1)..all_users.count-1
                    user_similarity_score = self.similarity_score(all_users[i], all_users[j])
                    UserSimilarityScore.create(:user1_id => all_users[i].id, :user2_id => all_users[j].id, :score => user_similarity_score) if user_similarity_score != 0
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

            user_1_products.map{|pbc| buy_count_1[pbc.product_id] = pbc.count}
            user_2_products.map{|pbc| buy_count_2[pbc.product_id] = pbc.count}

            pearson_similarity_score(common_product_ids, buy_count_1, buy_count_2) 
        end

        private
        def self.pearson_similarity_score(common_products, buy_count_1, buy_count_2)
            n = common_products.size
            return 0 if n == 0
            sum1 = common_products.inject(0.0){|sum, m| sum + buy_count_1[m]}
            sum2 = common_products.inject(0.0){|sum, m| sum + buy_count_2[m]}

            sum_sq1 = common_products.inject(0.0){|sum, m| sum += (buy_count_1[m] ** 2)}
            sum_sq2 = common_products.inject(0.0){|sum, m| sum += (buy_count_2[m] ** 2)}

            sum_of_products = common_products.inject(0){|sum, m| sum += (buy_count_1[m] * buy_count_2[m])}
            num = sum_of_products - (sum1 * sum2) / n
            den = Math.sqrt(((sum_sq1 - ((sum1 ** 2) / n)) * (sum_sq2 - ((sum2 ** 2) / n))).abs)
            return 0 if den == 0
            num/den
        end
    end
end
