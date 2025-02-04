# == Schema Information
#
# Table name: schedules
#
#  id                  :bigint           not null, primary key
#  date                :date             not null
#  expected_entry_time :datetime
#  expected_exit_time  :datetime
#  include_lunch       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :bigint
#
# Indexes
#
#  index_schedules_on_group_id_and_date  (group_id,date) UNIQUE
#
require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
