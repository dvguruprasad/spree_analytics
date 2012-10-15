Spree::ProductsController.class_eval do
    after_filter :record_behavior, :only  => :show

    private
    def record_behavior
        UserBehavior.record_search(@product, spree_current_user, session["session_id"])
    end
end
