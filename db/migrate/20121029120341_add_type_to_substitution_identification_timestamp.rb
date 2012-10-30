class AddTypeToSubstitutionIdentificationTimestamp < ActiveRecord::Migration
  def change
      add_column :substitution_identification_timestamp, :type, :string
  end
end
