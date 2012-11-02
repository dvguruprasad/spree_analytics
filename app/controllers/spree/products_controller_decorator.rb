Spree::ProductsController.class_eval do
    after_filter :record_search_behavior, :only  => :show

    def show
        return unless @product

        @variants = Spree::Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
        @product_properties = Spree::ProductProperty.includes(:property).where(:product_id => @product.id)

        referer = request.env['HTTP_REFERER']
        if referer
            referer_path = URI.parse(request.env['HTTP_REFERER']).path
            if referer_path && referer_path.match(/\/t\/(.*)/)
                @taxon = Spree::Taxon.find_by_permalink($1)
            end
        end

        @substitutes = @product.substitutes
        if !@substitutes.empty? && @substitutes.first[:probability] > Spree::Config.probability_threshold_for_discounts && current_user_is_loyal?
            @promotion = {}
            @promotion[:product] = @substitutes.first[:product]
            @promotion[:discount] = 10
            @substitutes.shift
        end

        respond_with(@product)
    end


    private
    def record_search_behavior
        UserBehavior.record_search(@product, spree_current_user, session["session_id"]) unless spree_current_user.nil?
    end

    def current_user_is_loyal?
        !spree_current_user.nil? && spree_current_user.is_loyal?
    end
end
