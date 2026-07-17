# == Schema Information
#
# Table name: schedules
#
#  id                  :bigint           not null, primary key
#  date                :date             not null
#  expected_entry_time :datetime
#  expected_exit_time  :datetime
#  include_lunch       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :bigint
#
# Indexes
#
#  index_schedules_on_group_id_and_date  (group_id,date) UNIQUE
#
class Schedule < ApplicationRecord
  belongs_to :group

  # Validaciones
  validates :expected_entry_time, :expected_exit_time, presence: true
  validate :exit_time_after_entry_time

  before_validation :set_date_from_entry_time

  # Scopes
  default_scope -> { order(date: :desc) }
  scope :by_group, ->(group_id) { where(group_id: group_id) }
  # A UNIQUE index on (group_id, date) already guarantees a single row per pair,
  # so we only need deterministic ordering here. (Replaces Postgres-only
  # "DISTINCT ON", which SQLite does not support.)
  scope :latest_by_function, -> {
    order(:group_id, date: :desc, created_at: :desc)
  }

  # Métodos de instancia
  def formatted_duration
    total_seconds = effective_expected_exit_time - expected_entry_time
    total_seconds -= 1.hour if include_lunch? && total_seconds > 4.hours
    Time.at(total_seconds).utc.strftime("%H:%M horas")
  end

  # Determina si el horario cruza la medianoche (turno nocturno: entrada 20:00, salida 04:00).
  # Ambos datetimes se guardan sobre la fecha de entrada, por eso entrada > salida.
  def crosses_midnight?
    expected_entry_time > expected_exit_time
  end

  # La salida esperada real: si el turno cruza la medianoche, cae al día siguiente.
  # Usar siempre esta versión para comparar contra horas de salida reales.
  def effective_expected_exit_time
    crosses_midnight? ? expected_exit_time + 1.day : expected_exit_time
  end

  def day_of_week
    date.wday
  end

  def translated_day_of_week
    I18n.l(date, format: "%A")
  end

  private

  def set_date_from_entry_time
    self.date = expected_entry_time.to_date if expected_entry_time.present?
  end

  # Validación personalizada: La hora de salida debe ser posterior a la hora de entrada
  def exit_time_after_entry_time
    return unless expected_entry_time && expected_exit_time

    if expected_entry_time >= expected_exit_time && !crosses_midnight?
      errors.add(:expected_exit_time, "debe ser posterior a la hora de entrada")
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "date", "expected_entry_time", "expected_exit_time", "group_id", "id", "include_lunch", "updated_at" ]
  end
end
