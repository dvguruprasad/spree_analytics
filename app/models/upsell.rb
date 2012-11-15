class Upsell < Substitution
  def self.last_capture_timestamp
    UpsellIdentificationTimestamp.read_and_update
  end

  def self.identify_substitutions(behaviors)
    substitutions = Hash.new(0)
    behavior_list = {}
    behaviors.each do |behavior|
      if behavior.searched_and_available?
        product_category = category(behavior.product)
        behavior_list[product_category] ||= []
        behavior_list[product_category] << behavior if ! behavior_list[product_category].include? behavior
      elsif behavior.purchase?
        products_by_category = products_grouped_by_category(behavior.products)
        products_by_category.each do |category, products|
          behavior_list[category] ||= []
          behavior_list[category] = behavior_list[category].reject do |p| ####Removing search behaviors which were part of the purchase!
            products.include? p.product
          end
          behavior_list[category].each do |searched_product|
            products.each do |bought_product|
              if(is_an_upsell(searched_product, bought_product, behavior.order))
                substitutions[substitution(searched_product.product, bought_product)] += 1
              end
            end
          end
          behavior_list[category].clear
        end
      end
    end
    return substitutions.collect {|s, c| s.count = c; s}
  end

  private
  def self.is_an_upsell(search_behavior, bought_product_id, order_id)
    bought_product = Spree::Product.find(bought_product_id)
    order = Spree::Order.find(order_id)
    order.line_items.any? do |line_item|
      product = line_item.variant.product
      product == bought_product && category(search_behavior.product) == product.category_taxon && line_item.price > search_behavior.price
    end
  end

  def self.cost(product)
    Spree::Product.find(product).variants.first.price
  end
end
