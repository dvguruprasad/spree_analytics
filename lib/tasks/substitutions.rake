task :capture_substitutions  => :environment do
    SubstitutionCount.capture_out_of_stock_substitutions
end
task :generate_probabilities => :environment do
    SubstitutionProbability.generate_probabilities
end

task :capture_substitutions_and_generate_probabilities => :environment do
    SubstitutionCount.capture_out_of_stock_substitutions
    SubstitutionProbability.generate_probabilities
end

task :gsp => :capture_substitutions_and_generate_probabilities
