Spree::Taxon.instance_eval do
    has_one :taxon_configuration
end

Spree::Taxon.class_eval do
    BRAND_LIST = ["nike","reebok","adidas","puma"]

    def substitutions_enabled?
        !taxon_configuration.nil? && taxon_configuration.recommendation_type == "sub"
    end

    def recommendations_enabled?
        !taxon_configuration.nil? && taxon_configuration.recommendation_type == "rec"
    end

    def sentiment_analysis_enabled?
        BRAND_LIST.include? name.downcase
    end
end
