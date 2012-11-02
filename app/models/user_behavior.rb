class UserBehavior < ActiveRecord::Base
    self.table_name = "spree_user_behaviors"

    def self.record_search(product, user, session_id)
        price = product.variants.empty? ? product.master.price : product.least_priced_variant.price
        create_behavior('S', "{\"product\": #{product.id}, \"available\": #{!product.out_of_stock?}, \"price\":#{price}}", user, session_id)
    end


    def self.record_purchase(order_id, product_ids, user, session_id)
        create_behavior('P',  "{\"products\": #{product_ids.inspect}, \"order\": #{order_id}}", user, session_id)
    end

    def self.search_count(searched_product, is_available)
      parameters ="{\"product\": #{searched_product}, \"available\": #{is_available}" 
      not_available_count = UserBehavior.count(:all, :conditions => ["action = ? AND parameters LIKE ?", 'S', "#{parameters}%"])
      not_available_count
    end

    def self.record_add_to_cart(product_id, order_id, user, session_id)
        create_behavior('A',  "{\"product\": #{product_id}, \"order\": #{order_id}}", user, session_id)
    end

    def self.record_remove_from_cart(product_id, order_id, user, session_id)
        create_behavior('R',  "{\"product\": #{product_id}, \"order\": #{order_id}}", user, session_id)
    end

    def self.all_user_behavior_since(user_id, last_capture_timestamp)
        find(:all, :conditions => ["user_id = ? and created_at > ?", user_id, last_capture_timestamp])
    end

    def searched_and_not_available?
        action == 'S' && !JSON.parse(parameters)["available"]
    end

    def searched_and_available?
        action == 'S' && JSON.parse(parameters)["available"]
    end

    def purchase?
        action == 'P'
    end

    def product
        JSON.parse(parameters)["product"]
    end

    def products
        JSON.parse(parameters)["products"]
    end

    def price
        JSON.parse(parameters)["price"]
    end

    def order
        JSON.parse(parameters)["order"]
    end

    private
    def self.create_behavior(action, parameters, user, session_id)
        userBehavior = UserBehavior.new
        userBehavior.action = action
        userBehavior.parameters = parameters
        userBehavior.session_id = session_id
        userBehavior.user_id = user.id
        userBehavior.save!
    end
end
