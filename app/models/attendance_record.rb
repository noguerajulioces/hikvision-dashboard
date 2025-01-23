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
class AttendanceRecord < ApplicationRecord
  belongs_to :employee
  belongs_to :device

  validates :entry_time, presence: true

  default_scope { order(entry_time: :desc) }
end
