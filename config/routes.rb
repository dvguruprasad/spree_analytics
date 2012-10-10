Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  get "/rfp", :to => "rfp#index"
  match "order_value" =>  "rfp#order_value_to_product"
end

