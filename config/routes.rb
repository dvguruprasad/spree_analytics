Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "/rfm", :to => "rfm#index"
  match "monetary_customer_distribution" =>  "rfm#monetary_customer_distribution"
  match "recency_customer_distribution" =>  "rfm#recency_customer_distribution"
  match "frequency_customer_distribution" =>  "rfm#frequency_customer_distribution"
end

