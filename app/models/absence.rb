# == Schema Information
#
# Table name: absences
#
#  id           :bigint           not null, primary key
#  absence_type :integer
#  end_date     :date
#  reason       :string
#  start_date   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  employee_id  :bigint           not null
#
# Indexes
#
#  index_absences_on_employee_id  (employee_id)
#
# Foreign Keys
#
#  fk_rails_...  (employee_id => employees.id)
#
class Absence < ApplicationRecord
  belongs_to :employee

  enum :absence_type, {
    vacation: 0,        # Vacaciones
    medical: 1,         # Licencia médica
    personal: 2,        # Asuntos personales
    unpaid: 3           # Licencia sin sueldo
  }

  validates :start_date, :end_date, :absence_type, presence: true
  validate :end_date_after_start_date

  # Validación personalizada para asegurarse de que la fecha de fin sea posterior a la de inicio
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "debe ser posterior a la fecha de inicio")
    end
  end

  def effective_days
    (start_date..end_date).reject { |date| date.sunday? }.count
  end

  def translated_absence_type
    I18n.t("enums.absence.absence_type.#{absence_type}")
  end

  def self.absence_types_collection
    absence_types.keys.map do |key|
      [ I18n.t("enums.absence.absence_type.#{key}"), key ]
    end
  end
end
