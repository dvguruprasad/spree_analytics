class UserBehavior < ActiveRecord::Base
    set_table_name :spree_user_behaviors

    def self.record_search(product, user, session_id)
        create_behavior('S', "{\"product\": #{product.id}, \"available\": #{!product.out_of_stock?} }", user, session_id)
    end

    def self.record_purchase(order_id, product_ids, user, session_id)
        product_ids.each do |product|
            create_behavior('P',  "{\"product\": #{product}, \"order\": #{order_id}}", user, session_id)
        end
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
