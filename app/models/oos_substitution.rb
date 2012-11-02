class OOSSubstitution < Substitution

  def self.last_capture_timestamp
    OOSSubstitutionIdentificationTimestamp.read_and_update
  end

  def self.identify_substitutions(behaviors)
    stacks = Hash.new
    substitutions_hash = Hash.new(0)
    behaviors.each do |behavior|
      if behavior.searched_and_not_available?
        category = category(behavior.product)
        stacks[category] ||= []
        stacks[category].pop if !stacks[category].empty?
        stacks[category] << behavior
      elsif behavior.purchase?
        products_by_category = products_grouped_by_category(behavior.products)
        products_by_category.each do |category, products|
          next if stacks[category].nil? || stacks[category].empty?
          products.each do |p|
            searched_product = stacks[category].first.product
            if is_a_substitution(searched_product, p)
              substitutions_hash[substitution(searched_product, p)]  += 1
            end
          end
          stacks[category].pop
        end
      end
    end
    substitutions_hash.collect {|s,c| s.count = c; s}
  end

  private
  def self.is_a_substitution(searched, bought)
    return false if searched == bought
    searched_product = Spree::Product.find_by_id(searched)
    bought_product = Spree::Product.find_by_id(bought)
    searched_product.category_taxon == bought_product.category_taxon
  end
end
