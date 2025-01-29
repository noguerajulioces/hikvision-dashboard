# == Schema Information
#
# Table name: employees
#
#  id               :integer          not null, primary key
#  document_number  :string
#  email            :string
#  first_name       :string
#  hire_date        :date
#  last_name        :string
#  phone            :string
#  termination_date :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  group_id         :integer
#
class Employee < ApplicationRecord
  belongs_to :group, optional: true
  has_many :attendance_records, dependent: :destroy
  has_many :overtime_records, dependent: :destroy
  has_many :incidents, dependent: :destroy
  has_many :absences, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :hire_date, presence: true
  validates :email, uniqueness: true, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, allow_blank: true, length: { minimum: 10, maximum: 15 }
  validates :document_number, presence: true, uniqueness: true

  def self.margin_of_tolerance
    Setting&.margin_of_tolerance&.to_i&.minutes || 5.minutes
  end

  # Verificar si el empleado tiene una licencia en una fecha específica
  def on_leave?(date)
    absences.exists?([ "start_date <= ? AND end_date >= ?", date, date ])
  end

  # Método para obtener el nombre completo del empleado
  def full_name
    "#{first_name} #{last_name}"
  end

  # Obtener registros de asistencia no procesados en un rango de fechas
  def unprocessed_attendance_records(start_date, end_date)
    attendance_records.where(processed: false, entry_time: start_date.beginning_of_day..end_date.end_of_day)
                      .reject { |record| on_leave?(record.entry_time.to_date) }
  end

  # Calcular las horas trabajadas excluyendo almuerzo
  def calculate_worked_hours(records)
    records.sum do |record|
      hours = (record.exit_time - record.entry_time) / 3600.0
      cross_midnight = record.entry_time.to_date != record.exit_time.to_date

      # Descontar 1 hora si no cruza la medianoche y si trabaja más de 4 horas
      hours -= 1 if hours > 4 && !cross_midnight
      hours
    end
  end

  # Calcular horas extras (e.g., más de 8 horas por día)
  def calculate_overtime(records, standard_hours = 8)
    records.sum do |record|
      hours = (record.exit_time - record.entry_time) / 3600.0
      [ hours - standard_hours, 0 ].max
    end
  end
end
