Spree::ProductsController.class_eval do
    after_filter :record_search_behavior, :only  => :show

    private
    def record_search_behavior
        UserBehavior.record_search(@product, spree_current_user, session["session_id"]) unless spree_current_user.nil?
    end
end
