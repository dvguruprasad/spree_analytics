class SubstitutionsCaptor
    def self.capture
        all_users = Spree.user_class.find(:all, :select => :id)
        all_users.each do |user|
            substitutions_by_user = find_all_substitutions_by_user(user)
            create_or_update(substitutions_by_user)
        end
    end

    private
    def self.find_all_substitutions_by_user(user)
        behaviors = UserBehavior.find_all_by_user_id(user)
        behaviors = [] if behaviors.nil?
        stack = []
        substitutions = Hash.new(0)
        behaviors.each do |behavior|
            if behavior.searched_and_not_available?
                stack << behavior
            elsif behavior.purchase?
                if !stack.empty?
                    searched_product = stack.pop.product
                    bought_product = behavior.product
                    count = substitutions[substitution(searched_product, bought_product)]  
                    substitutions[substitution(searched_product, bought_product)]  = count + 1
                end
            end
        end
        substitutions
    end

    def self.create_or_update(substitutions)
        substitutions.each do |substitution, count|
            substitution.count = count
            substitution.create_or_update_substitution
        end
    end

    def self.substitution(searched_product, bought_product)
        substitution = SubstitutionCount.new
        substitution.searched_product = searched_product
        substitution.bought_product = bought_product
        substitution
    end
end
