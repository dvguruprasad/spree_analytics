namespace :s do
    namespace :oos do
        task :capture => :environment do
            OOSSubstitution.capture
        end
        task :generate_probabilities => :environment do
            OOSSubstitutionProbability.generate_probabilities
        end

        task :all => :environment do
            OOSSubstitution.capture
            OOSSubstitutionProbability.generate_probabilities
        end

        task :clear => :environment do
            OOSSubstitution.delete_all
            OOSSubstitutionProbability.delete_all
            OOSSubstitutionIdentificationTimestamp.delete_all
        end

        task :gsp => :all
    end

    namespace :upsell do
        task :capture => :environment do
            Upsell.capture
        end
        task :generate_probabilities => :environment do
            UpsellProbability.generate_probabilities
        end

        task :all => :environment do
            Upsell.capture
            UpsellProbability.generate_probabilities
        end

        task :clear => :environment do
            Upsell.delete_all
            UpsellProbability.delete_all
            UpsellIdentificationTimestamp.delete_all
        end

        task :gsp => :all
    end

    task :gsp => ["oos:gsp", "upsell:gsp"]
    task :clear_all => ["oos:clear", "upsell:clear"]
end
