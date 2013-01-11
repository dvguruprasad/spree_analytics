Rails.application.routes.draw do

  get "/admin/rfm", :to => "rfm#index", :as => :rfm
  get "sentiment", :to => "sentiment#show"
  get "telescope", :to => "telescope#index"

  match "/admin/monetary_customer_distribution" =>  "rfm#monetary_customer_distribution"
  match "/admin/recency_customer_distribution" =>  "rfm#recency_customer_distribution"
  match "/admin/frequency_customer_distribution" =>  "rfm#frequency_customer_distribution"
end

