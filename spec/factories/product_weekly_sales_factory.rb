FactoryGirl.define do
  factory :product_weekly_sales do |s|
      s.product_id 1111
      s.sales_units 100
      s.target_sales_units 150
      s.revenue 1000.0
      s.target_revenue 1500.0
      s.cost 8.0
  end

  factory :product_weekly_sales_forecast, :class => ProductWeeklySalesForecast, parent: :product_weekly_sales do |s|
  end
end
