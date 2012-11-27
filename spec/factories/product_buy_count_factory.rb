FactoryGirl.define do
    factory :product_buy_count, :class => Recommendation::ProductBuyCount do |p|
      p.count 2
      p.product_id 1111
    end
end
