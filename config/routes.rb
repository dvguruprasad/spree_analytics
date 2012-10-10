Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match "order_value" =>  "rfp#order_value_to_product"

  get "/rfp", :to => "rfp#index"
end

