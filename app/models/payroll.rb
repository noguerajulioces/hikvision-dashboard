# == Schema Information
#
# Table name: payrolls
#
#  id                   :integer          not null, primary key
#  comments             :text
#  end_date             :date
#  start_date           :date
#  total_hours_worked   :decimal(15, 2)
#  total_incidents      :integer
#  total_overtime_hours :decimal(15, 2)
#  total_payment        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  employee_id          :integer          not null
#
# Indexes
#
#  index_payrolls_on_employee_id  (employee_id)
#
# Foreign Keys
#
#  employee_id  (employee_id => employees.id)
#
class Payroll < ApplicationRecord
  belongs_to :employee

  has_many :overtime_records, through: :employee
  has_many :attendance_records, through: :employee
  has_many :incidents, through: :employee

  validates :start_date, :end_date, presence: true

  default_scope { order(created_at: :desc) }

  # Método principal para calcular los totales
  def calculate_totals(include_lunch)
    # Calcular totales en base al rango de fechas
    self.total_hours_worked = attendance_records.where(entry_time: start_date.beginning_of_day..end_date.end_of_day).sum do |record|
      record.exit_time ? (record.exit_time - record.entry_time) / 3600.0 : 0
    end

    self.total_overtime_hours = overtime_records.where(date: start_date..end_date).sum(:hours_worked)
    self.total_incidents = incidents.where(date: start_date..end_date).count
    self.total_payment = calculate_payment
  end

  private

  def calculate_payment
    base_payment = total_hours_worked * hourly_rate
    overtime_payment = total_overtime_hours * overtime_rate
    penalty = total_incidents * incident_penalty
    base_payment + overtime_payment - penalty
  end

  def hourly_rate
    10_000.0
  end

  def overtime_rate
    25_000.0
  end

  def incident_penalty
    5.0
  end
end
