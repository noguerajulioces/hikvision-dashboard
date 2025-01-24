# == Schema Information
#
# Table name: attendance_records
#
#  id          :integer          not null, primary key
#  entry_time  :datetime
#  exit_time   :datetime
#  processed   :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  device_id   :integer
#  employee_id :integer
#
require "test_helper"

class AttendanceRecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
