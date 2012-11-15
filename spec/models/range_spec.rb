require 'spec_helper'

class RangeSpec
  describe "Range" do
    context "#split" do
      it "should return the same range if the number buckets is 1" do
        range = Range.new(1,1000)
        list_of_ranges = range.split(1)
        list_of_ranges.count.should eql 1
        list_of_ranges.first.should eql range
      end
    end
  end
end

