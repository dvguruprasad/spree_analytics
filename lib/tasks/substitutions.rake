require "#{File.expand_path(File.dirname(__FILE__))}/substitutions_captor"

task :capture_substitutions  => :environment do
    SubstitutionsCaptor.capture
end
task :generate_probabilities => :environment do
    SubstitutionProbability.generate_probabilities
end

task :capture_substitutions_and_generate_probabilities => :environment do
    SubstitutionsCaptor.capture
    SubstitutionProbability.generate_probabilities
end

task :gsp => :capture_substitutions_and_generate_probabilities