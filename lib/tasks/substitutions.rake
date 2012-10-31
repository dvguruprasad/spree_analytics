namespace :substitutions do
    namespace :oos do
        task :capture => :environment do
            OOSSubstitutionCount.capture
        end
        task :generate_probabilities => :environment do
            OOSSubstitutionProbability.generate_probabilities
        end

        task :capture_and_generate_probabilities => :environment do
            OOSSubstitutionCount.capture
            OOSSubstitutionProbability.generate_probabilities
        end

        task :gsp => :capture_and_generate_probabilities
    end

    namespace :upsell do
        task :capture => :environment do
            UpsellSubstitutionCount.capture
        end
        task :generate_probabilities => :environment do
            UpsellSubstitutionProbability.generate_probabilities
        end

        task :capture_and_generate_probabilities => :environment do
            UpsellSubstitutionCount.capture
            UpsellSubstitutionProbability.generate_probabilities
        end

        task :gsp => :capture_and_generate_probabilities
    end

    task :gsp => ["oos:gsp", "upsell:gsp"]
end
