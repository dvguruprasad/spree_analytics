module Recommendation
    class CFRecommendation < ActiveRecord::Base
        self.table_name = "spree_cf_recommendations"
        attr_accessible :user_id, :product_ids

        def self.generate
            all_user_ids = ProductBuyCount.select(:user_id).uniq.collect{|pbc| pbc.user_id}
            for i in 0..all_user_ids.count-1
                user = Spree.user_class.find(all_user_ids[i])
                similar_users_score_hash = UserSimilarityScore.similar_to(user.id)
                weighted_buy_count_sums = self.weighted_buy_count_sums(similar_users_score_hash, user)
                final_product_weights = {}
                weighted_buy_count_sums.each do |product_id, weighted_buy_count|
                    final_product_weights[product_id] = weighted_buy_count / similarity_score_sum(similar_users_score_hash, product_id)
                end
                result = Hash[final_product_weights.sort_by{|product_id, weight| weight}.reverse].keys
                self.create_or_update(user.id, result) unless result.empty?
            end

        end

        def self.for_user(user)
            recommendation = find_by_user_id(user.id)
            return [] if recommendation.nil?
            product_ids = JSON.parse(recommendation.product_ids)

            product_ids.collect do |p_id|
                Spree::Product.find(p_id) if ! user.has_bought? p_id
            end.take(6)
        end

        private

        def self.create_or_update(user_id, result)
            cf_recommendation = CFRecommendation.find_by_user_id(user_id)
            if cf_recommendation.nil?
                CFRecommendation.create(:user_id => user_id,:product_ids => result.to_json)
            else
                cf_recommendation.product_ids = result.to_json
                cf_recommendation.save
            end
        end

        def self.weighted_buy_count_sums(similar_users, user)
            weighted_buy_count_sums = {}
            similar_users.each do |similar_user,score|
                similar_user.product_buy_counts.collect do |pbc|
                    next if user.has_bought? pbc.product_id
                    weighted_buy_count_sums[pbc.product_id] ||= 0
                    weighted_buy_count_sums[pbc.product_id] += pbc.count * score
                end
            end
            weighted_buy_count_sums
        end

        def self.similarity_score_sum(similar_users, product_id)
            similar_users.inject(0) do |sum, (similar_user,score)|
                sum += (similar_user.has_bought?(product_id)) ? score : 0
            end
        end

    end
end
