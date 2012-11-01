namespace :s do
    namespace :oos do
        task :capture => :environment do
            OOSSubstitutionCount.capture
        end
        task :generate_probabilities => :environment do
            OOSSubstitutionProbability.generate_probabilities
        end

        task :all => :environment do
            OOSSubstitutionCount.capture
            OOSSubstitutionProbability.generate_probabilities
        end

        task :clear => :environment do
            OOSSubstitutionCount.delete_all
            OOSSubstitutionProbability.delete_all
            OOSSubstitutionIdentificationTimestamp.delete_all
        end

        task :gsp => :all
    end

    namespace :upsell do
        task :capture => :environment do
            UpsellSubstitutionCount.capture
        end
        task :generate_probabilities => :environment do
            UpsellSubstitutionProbability.generate_probabilities
        end

        task :all => :environment do
            UpsellSubstitutionCount.capture
            UpsellSubstitutionProbability.generate_probabilities
        end

        task :clear => :environment do
            UpsellSubstitutionCount.delete_all
            UpsellSubstitutionProbability.delete_all
            UpsellSubstitutionIdentificationTimestamp.delete_all
        end

        task :gsp => :all
    end

    task :gsp => ["oos:gsp", "upsell:gsp"]
    task :clear_all => ["oos:clear", "upsell:clear"]
end
