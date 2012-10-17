class SubstitutionsCapturor
    def self.capture
        all_users = User.find(:all, :select => :id)
        all_users.each do |user|
            substitutions_by_user = find_all_substitutions_by_user(user)
            create_or_update(substitutions_by_user)
        end
    end

    private 
    def find_all_substitutions_by_user(user)
        behaviors = UserBehavior.find_by_user_id(user)
    end
end
