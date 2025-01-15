# == Schema Information
#
# Table name: schedules
#
#  id                  :integer          not null, primary key
#  day_of_week         :string
#  expected_entry_time :time
#  expected_exit_time  :time
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :integer
#
require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
