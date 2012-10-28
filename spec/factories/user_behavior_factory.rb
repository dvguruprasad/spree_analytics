FactoryGirl.define do
    factory :search_behavior, :class => UserBehavior do
        ignore do
            product 1
            is_available true
        end
        action "S"
        parameters { "{\"product\": #{product}, \"available\": #{is_available} }"}
    end

    factory :purchase_behavior ,:class => UserBehavior do
        ignore do
            products [1]
            order 111
        end
        action "P"
        parameters { "{\"products\": #{products.inspect}, \"order\": #{order} }"}
    end

    factory :add_to_cart_behavior ,:class => UserBehavior do
        ignore do
            product 1
        end
        action "A"
    end
end
