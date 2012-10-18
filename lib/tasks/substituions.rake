require "#{File.expand_path(File.dirname(__FILE__))}/substitutions_captor"

task :capture_substitutions  => :environment do
    SubstitutionsCaptor.capture
end

