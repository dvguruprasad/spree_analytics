class UpsellSubstitutionCount < SubstitutionCount
  def self.last_capture_timestamp
    UpsellSubstitutionIdentificationTimestamp.read_and_update
  end
end
