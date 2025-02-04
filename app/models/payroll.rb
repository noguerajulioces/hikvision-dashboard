# == Schema Information
#
# Table name: payrolls
#
#  id                   :bigint           not null, primary key
#  comments             :text
#  end_date             :date
#  start_date           :date
#  total_hours_worked   :decimal(15, 2)
#  total_incidents      :integer
#  total_overtime_hours :decimal(15, 2)
#  total_payment        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  employee_id          :bigint           not null
#
# Indexes
#
#  index_payrolls_on_employee_id  (employee_id)
#
# Foreign Keys
#
#  fk_rails_...  (employee_id => employees.id)
#
class Payroll < ApplicationRecord
  belongs_to :employee

  has_many :payroll_entries, dependent: :destroy
  has_many :attendance_records, through: :payroll_entries, source: :recordable, source_type: "AttendanceRecord"
  has_many :overtime_records, through: :payroll_entries, source: :recordable, source_type: "OvertimeRecord"
  has_many :incidents, through: :payroll_entries, source: :recordable, source_type: "Incident"

  validates :start_date, :end_date, presence: true

  default_scope { order(created_at: :desc) }

  # Método principal para calcular los totales
  def calculate_totals(include_lunch)
    # Calcular totales en base al rango de fechas
    self.total_hours_worked = attendance_records.where(entry_time: start_date.beginning_of_day..end_date.end_of_day).sum do |record|
      if record.exit_time
        hours = (record.exit_time - record.entry_time) / 3600.0
        # Subtract lunch hour if worked more than 4 hours and include_lunch is true
        include_lunch && hours > 4 ? hours - Setting&.lunch_hours : hours
      else
        0
      end
    end

    self.total_overtime_hours = overtime_records.where(date: start_date..end_date).sum(:hours_worked)
    self.total_incidents = incidents.where(date: start_date..end_date).count
    self.total_payment = calculate_payment
  end

  def unresolved_incidents
    self.incidents.where(resolved: false)&.count
  end
  private

  def calculate_payment
    base_payment = total_hours_worked * hourly_rate
    overtime_payment = total_overtime_hours * overtime_rate
    base_payment + overtime_payment
  end

  def hourly_rate
    Setting.hourly_rate
  end

  def overtime_rate
    Setting.overtime_rate
  end
end
