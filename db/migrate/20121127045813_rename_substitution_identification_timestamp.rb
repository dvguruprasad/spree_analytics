class RenameSubstitutionIdentificationTimestamp < ActiveRecord::Migration
    def change
        rename_table :substitution_identification_timestamp, :recommendation_identification_timestamps
    end
end
