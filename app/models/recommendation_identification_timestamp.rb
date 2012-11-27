class RecommendationIdentificationTimestamp < ActiveRecord::Base
  self.table_name = "recommendation_identification_timestamps"

  attr_accessible :value,:substitution_type

  def self.read_and_update
    timestamp = self.find(:first)
    if timestamp
      last_capture_timestamp = timestamp.value
      timestamp.value = DateTime.now
      timestamp.save!
    else
      last_capture_timestamp =  DateTime.new(1970, 1, 1)
      self.create!(:value => DateTime.now)
    end
    last_capture_timestamp
  end
end
