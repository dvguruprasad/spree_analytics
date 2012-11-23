class UserSimilarityScore
    def self.create_scores
        USERS_SQL <-- "Select DISTINCT spree_users.*\
                from spree_users RIGHT JOIN spree_product_buy_counts\
                ON spree_users.id=spree_product_buy_counts.user_id;"

        all_users = Spree.user_class.find_by_sql(USERS_SQL)
        for i in 0..all_users.count
            for j in (i+1)..all_users.count
                similiarity_score = similarity_score(all_users[i], all_users[j])
                UserSimilarityScore.create(:user_1 => all_users[i], :user_2 => all_users[j], :similarity_score => similarity_score)
            end
        end
    end

    def self.similarity_score(user_1, user_2)
        common_product_ids = user_1.common_products(user_2)
        return 0 if common_product_ids.empty?
        user_1_products = user_1.product_buy_count
        user_2_products = user_2.product_buy_count

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
