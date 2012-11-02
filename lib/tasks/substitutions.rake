namespace :s do
    namespace :oos do
        task :capture => :environment do
            OOSSubstitution.capture
        end
        task :generate_probabilities => :environment do
            SubstitutionProbability.generate_for_oos_substitution
        end

        task :gsp => [:capture, :generate_probabilities]

        task :clear => :environment do
            OOSSubstitution.delete_all
            OOSSubstitutionProbability.delete_all
            OOSSubstitutionIdentificationTimestamp.delete_all
        end
    end

    namespace :upsell do
        task :capture => :environment do
            Upsell.capture
        end

        task :generate_probabilities => :environment do
            SubstitutionProbability.generate_for_upsell
        end

        task :gsp => [:capture, :generate_probabilities]

        task :clear => :environment do
            Upsell.delete_all
            UpsellProbability.delete_all
            UpsellIdentificationTimestamp.delete_all
        end
    end

    task :gsp => ["oos:gsp", "upsell:gsp"]
    task :clear => ["oos:clear", "upsell:clear"]
end
