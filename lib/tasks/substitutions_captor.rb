class SubstitutionsCaptor
    def self.capture
        last_capture_timestamp = SubstitutionIdentificationTimestamp.read_and_update
        all_users = Spree.user_class.find(:all, :select => :id)
        all_users.each do |user|
            substitutions = user.substitutions_since(last_capture_timestamp)
            create_or_update(substitutions)
        end
    end

    private
    def self.create_or_update(substitutions)
        substitutions.each do |substitution|
            substitution = substitution.create_or_update_substitution
            p "Substitution found between: #{substitution.searched_product} and #{substitution.bought_product} with #{substitution.count} substitutions"
        end
    end
end
