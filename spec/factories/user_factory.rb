FactoryGirl.define do
    factory :user_with_pbc, :parent => :user do |user|
        user.email "spree_test_user@thoughtworks.com"
    end
end


