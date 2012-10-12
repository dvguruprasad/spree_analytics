require 'spree_core'
require 'spree_analytics/engine'

Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
  # Rails.application.config.cache_classes ? require(c) : load(c)
end
