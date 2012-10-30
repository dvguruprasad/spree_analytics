task :capture_substitutions  => :environment do
    OOSSubstitutionCount.capture
end
task :generate_probabilities => :environment do
    SubstitutionProbability.generate_probabilities
end

task :capture_substitutions_and_generate_probabilities => :environment do
    OOSSubstitutionCount.capture
    SubstitutionProbability.generate_probabilities
end

task :gsp => :capture_substitutions_and_generate_probabilities
