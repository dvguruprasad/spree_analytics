require 'rspec'
require 'factory_girl_rails'
FactoryGirl.find_definitions

require "#{File.dirname(__FILE__)}/../../lib/tasks/substitutions_captor"

class SubstitutionCaptorSpec
    describe "SubstitutionCaptor" do
        it "should not create any substitutions when the only behavior is search" do
            user = FactoryGirl.create(:user)
            substitutionCount = Count.new
            behavior = UserBehavior.new
            behavior.user_id = user.id
            behavior.action = 'S'
            behavior.parameters = '{\"product\": 12345, \"available\": true}'
            behavior.save

            SubstitutionCaptor.capture
            SubstitutionCount.count.should eql 0
        end
    end
end
