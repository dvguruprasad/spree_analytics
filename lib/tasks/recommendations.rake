namespace :rec do
    namespace :cf do
        task :generate => :environment do
            Recommendation::ProductBuyCount.generate
            Recommendation::UserSimilarityScore.create_scores
            Recommendation::CFRecommendation.generate
        end
        task :clear_all => :environment do
            Recommendation::ProductBuyCount.delete_all
            Recommendation::UserSimilarityScore.delete_all
            Recommendation::CFRecommendation.delete_all
            Recommendation::CFRecommendationIdentificationTimestamp.delete_all
        end
    end
end
