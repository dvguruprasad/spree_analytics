class SubstitutionCount < ActiveRecord::Base
  self.table_name = "spree_substitution_counts"

  def self.capture
    all_users = Spree.user_class.find(:all, :select => :id)
    timestamp = self.last_capture_timestamp
    all_users.each do |user|
      substitutions = user.substitutions_since(timestamp, self)
      substitutions.each do |substitution|
        p "#{substitution.count} out of stock substitution found between: #{substitution.searched_product} and #{substitution.bought_product}"
        substitution = substitution.create_or_update_substitution
      end
    end
  end

  def create_or_update_substitution
    substitution = self.class.find_or_create_by_searched_product_and_bought_product(searched_product,bought_product)
    substitution.count=0 if substitution.count.nil?
    substitution.count += 1
    substitution.save
    substitution
  end


  def eql?(other)
    searched_product == other.searched_product && bought_product == other.bought_product
  end
end
