# == Schema Information
#
# Table name: schedules
#
#  id                  :integer          not null, primary key
#  day_of_week         :integer
#  expected_entry_time :time
#  expected_exit_time  :time
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :bigint
#
class Schedule < ApplicationRecord
  belongs_to :group

  # Constantes
  DAYS_OF_WEEK = {
    monday: 0,
    tuesday: 1,
    wednesday: 2,
    thursday: 3,
    friday: 4,
    saturday: 5,
    sunday: 6
  }.freeze

  # Enums
  enum :day_of_week, DAYS_OF_WEEK, suffix: true

  # Validaciones
  validates :expected_entry_time, :expected_exit_time, presence: true
  validate :exit_time_after_entry_time

  # Scopes
  default_scope { order(:group_id, :day_of_week) }
  scope :by_day, ->(day) { where(day_of_week: day) }
  scope :by_group, ->(group_id) { where(group_id: group_id) }

  # Métodos de clase
  def self.days_of_week_collection
    DAYS_OF_WEEK.map { |key, value| [ I18n.t("enums.schedule.day_of_week.#{key}", default: key.to_s.humanize), value ] }
  end

  # Métodos de instancia
  def translated_day_of_week
    I18n.t("enums.schedule.day_of_week.#{day_of_week}", default: day_of_week.humanize)
  end

  def formatted_duration
    seconds = expected_exit_time - expected_entry_time
    Time.at(seconds).utc.strftime("%H:%M horas")
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
