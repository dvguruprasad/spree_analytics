Spree::OrdersController.class_eval do
    after_filter :record_add_to_cart_behavior, :only => :populate

    def record_add_to_cart_behavior
        variants = params[:variants]
        variants.each do |variant_id, quantity|
            UserBehavior.record_add_to_cart(variant_id, @order.id, spree_current_user, session["session_id"])
        end
    end
end
