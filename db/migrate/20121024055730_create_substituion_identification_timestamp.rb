class CreateSubstituionIdentificationTimestamp < ActiveRecord::Migration
  def change
      create_table :substitution_identification_timestamp do |t|
          t.datetime :value
      end
  end
end
