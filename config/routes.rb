Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "/rfm", :to => "rfm#index"
  match "order_value" =>  "rfm#order_value_to_product"
end

