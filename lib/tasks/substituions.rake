require "#{File.expand_path(File.dirname(__FILE__))}/substitutions_capturor"

task :capture_substitutions  => :environment do
    SubstitutionsCapturor.capture
end

