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
class AttendanceRecord < ApplicationRecord
  belongs_to :employee
  belongs_to :device
  belongs_to :schedule, optional: true # Permite que sea nil si no hay un horario asociado

  validates :entry_time, presence: true

  default_scope { order(entry_time: :desc) }

  before_validation :assign_schedule
  after_initialize :set_defaults
  after_find :check_and_assign_schedule

  def hours_worked
    return 0 unless exit_time

    total_hours = ((exit_time - entry_time) / 3600.0)

    # Subtract lunch hour if schedule has lunch time
    if schedule&.include_lunch
      total_hours -= AppSetting&.lunch_hours
    end

    total_hours.round(2)
  end

  private

  def assign_schedule
    return unless entry_time && employee

    # Encuentra el horario basado en la fecha del registro y el grupo del empleado
    self.schedule = Schedule.find_by(
      group_id: employee.group_id,
      date: entry_time.to_date
    )
  end

  def check_and_assign_schedule
    if schedule.nil?
      assign_schedule
      save if schedule.present?
    end
  end

  def set_defaults
    self.processed ||= false
  end

  # Add these methods at the end of your model, before the final 'end'
  def self.ransackable_attributes(auth_object = nil)
    [ "entry_time", "exit_time", "processed", "employee_id", "device_id", "schedule_id", "created_at", "updated_at", "id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "employee", "device", "schedule" ]
  end
end
