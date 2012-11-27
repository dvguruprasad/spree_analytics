class TaxonConfiguration < ActiveRecord::Base
  self.table_name = "spree_taxon_configurations"
  attr_accessible :taxon_id, :recommendation_type
end
