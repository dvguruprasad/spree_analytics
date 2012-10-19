Spree::OrdersController.class_eval do
    after_filter :record_add_to_cart_behavior, :only => :populate

    def record_add_to_cart_behavior
        params[:variants].each do |variant_id, quantity|
            quantity = quantity.to_i
            if quantity > 0
                product_id = Spree::Variant.find_by_id(variant_id, :select => :product_id).product_id
                UserBehavior.record_add_to_cart(product_id, @order.id, spree_current_user, session["session_id"])
            end
        end if params[:variants]

        params[:products].each do |product_id,variant_id|
            quantity = params[:quantity].to_i if !params[:quantity].is_a?(Hash)
            quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Hash)
            UserBehavior.record_add_to_cart(product_id, @order.id, spree_current_user, session["session_id"]) if quantity > 0
        end if params[:products]
    end
end
