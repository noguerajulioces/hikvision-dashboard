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
#  schedule_id :integer
#
# Indexes
#
#  index_attendance_records_on_schedule_id  (schedule_id)
#
# Foreign Keys
#
#  schedule_id  (schedule_id => schedules.id)
#
class AttendanceRecord < ApplicationRecord
  belongs_to :employee
  belongs_to :device
  belongs_to :schedule, optional: true # Permite que sea nil si no hay un horario asociado

  validates :entry_time, presence: true

  default_scope { order(entry_time: :desc) }

  before_validation :assign_schedule

  private

  def assign_schedule
    return unless entry_time && employee

    # Encuentra el horario basado en la fecha del registro y el grupo del empleado
    self.schedule = Schedule.find_by(
      group_id: employee.group_id,
      date: entry_time.to_date
    )
  end

end
