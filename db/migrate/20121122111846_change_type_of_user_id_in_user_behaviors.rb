class ChangeTypeOfUserIdInUserBehaviors < ActiveRecord::Migration
    def change
        change_column :spree_user_behaviors, :user_id ,:integer
    end
end
