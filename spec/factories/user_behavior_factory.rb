FactoryGirl.define do
    factory :search_behavior, :class => UserBehavior do
        action "S"
    end

    factory :purchase_behavior ,:class => UserBehavior do
        action "P"
    end

    factory :add_to_cart_behavior ,:class => UserBehavior do
        action "A"
    end
end
