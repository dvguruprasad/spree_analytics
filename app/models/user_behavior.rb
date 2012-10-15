class UserBehavior < ActiveRecord::Base
    set_table_name :spree_user_behaviors

    def self.record_search(product, user, session_id)
        userBehavior = UserBehavior.new
        userBehavior.action = 'S'
        userBehavior.parameters = "{\"product\": #{product.id}}"
        userBehavior.session_id = session_id
        userBehavior.user_id = user.id
        userBehavior.save!
    end
end
