# == Schema Information
#
# Table name: attendance_records
#
#  id          :bigint           not null, primary key
#  entry_time  :datetime
#  exit_time   :datetime
#  processed   :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  device_id   :integer
#  employee_id :integer
#  schedule_id :bigint
#
# Indexes
#
#  index_attendance_records_on_schedule_id  (schedule_id)
#
# Foreign Keys
#
#  fk_rails_...  (schedule_id => schedules.id)
#
require "test_helper"

class AttendanceRecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
