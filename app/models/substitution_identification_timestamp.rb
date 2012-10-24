class SubstitutionIdentificationTimestamp < ActiveRecord::Base
    self.table_name = "substitution_identification_timestamp"

    attr_accessible :value

    def self.read_and_update
        timestamp = find(:first)
        if timestamp
            last_capture_timestamp = timestamp.value
            timestamp.value = DateTime.now
            timestamp.save!
        else
            last_capture_timestamp =  DateTime.new(1970, 1, 1)
            SubstitutionIdentificationTimestamp.create!(:value => DateTime.now)
        end
        last_capture_timestamp
    end
end
