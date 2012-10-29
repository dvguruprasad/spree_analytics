Spree::AppConfiguration.class_eval do
  preference :probability_threshold_for_discounts, :decimal, :default => 0.5
end
