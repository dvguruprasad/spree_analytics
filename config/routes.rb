Rails.application.routes.draw do

  get "rfm", :to => "rfm#index"
  get "sentiment", :to => "sentiment#show"
  get "telescope", :to => "telescope#index"

  match "monetary_customer_distribution" =>  "rfm#monetary_customer_distribution"
  match "recency_customer_distribution" =>  "rfm#recency_customer_distribution"
  match "frequency_customer_distribution" =>  "rfm#frequency_customer_distribution"
end

