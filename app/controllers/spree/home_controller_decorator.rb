Spree::HomeController.class_eval do
    before_filter :load_cf_recommendations, :only => :index

    def load_cf_recommendations
        @cf_recommendations = Recommendation::CFRecommendation.for_user(spree_current_user) unless spree_current_user.nil?
    end
end
