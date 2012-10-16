Spree::CheckoutController.class_eval do
    after_filter :record_behavior, :only => :update

    private
    def record_behavior
        if (@order.state == "complete" || @order.completed?) && !spree_current_user.nil?
            product_ids = @order.products.map{|p| p.id}
            UserBehavior.record_purchase(@order.id, product_ids, spree_current_user, session["session_id"])
        end
    end
end
