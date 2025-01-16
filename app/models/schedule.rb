# == Schema Information
#
# Table name: schedules
#
#  id                  :integer          not null, primary key
#  day_of_week         :string
#  expected_entry_time :time
#  expected_exit_time  :time
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :integer
#
class Schedule < ApplicationRecord
  belongs_to :group

  # Constantes
  DAYS_OF_WEEK = {
    1 => "lunes",
    2 => "martes",
    3 => "miércoles",
    4 => "jueves",
    5 => "viernes",
    6 => "sábado",
    7 => "domingo"
  }.freeze

  # Enums
  enum :day_of_week, DAYS_OF_WEEK, suffix: true

  # Validaciones
  validates :day_of_week, presence: true, inclusion: { in: DAYS_OF_WEEK.values }
  validates :expected_entry_time, :expected_exit_time, presence: true
  validate :exit_time_after_entry_time

  # Scopes
  scope :by_day, ->(day) { where(day_of_week: day) }
  scope :by_group, ->(group_id) { where(group_id: group_id) }

  # Métodos de instancia
  def translated_day_of_week
    I18n.t("enums.schedule.day_of_week.#{day_of_week}", default: day_of_week)
  end

  private

  # Validación personalizada: La hora de salida debe ser posterior a la hora de entrada
  def exit_time_after_entry_time
    return unless expected_entry_time && expected_exit_time

    if expected_entry_time >= expected_exit_time && !crosses_midnight?
      errors.add(:expected_exit_time, "debe ser posterior a la hora de entrada")
    end
  end

  # Determina si el horario cruza la medianoche
  def crosses_midnight?
    expected_entry_time > expected_exit_time
  end
end
