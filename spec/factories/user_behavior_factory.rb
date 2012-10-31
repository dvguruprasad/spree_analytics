FactoryGirl.define do
    factory :search_behavior, :class => UserBehavior do
        ignore do
            product 1
            is_available true
            price 10
        end
        action "S"
        user_id 1
        parameters { "{\"product\": #{product}, \"available\": #{is_available}, \"price\": #{price} }"}
    end

    factory :purchase_behavior ,:class => UserBehavior do
        ignore do
            products [1]
            order 111
        end
        action "P"
        user_id 1
        parameters { "{\"products\": #{products.inspect}, \"order\": #{order} }"}
    end

    factory :add_to_cart_behavior ,:class => UserBehavior do
        ignore do
            product 1
        end
        action "A"
        user_id 1
    end
end
