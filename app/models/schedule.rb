# == Schema Information
#
# Table name: schedules
#
#  id                  :bigint           not null, primary key
#  date                :date             not null
#  expected_entry_time :datetime
#  expected_exit_time  :datetime
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
  scope :latest_by_function, -> {
    select("DISTINCT ON (group_id, date) *").order("group_id, date DESC, created_at DESC")
  }

  # Métodos de instancia
  def formatted_duration
    seconds = expected_exit_time - expected_entry_time
    Time.at(seconds).utc.strftime("%H:%M horas")
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

  # Determina si el horario cruza la medianoche
  def crosses_midnight?
    expected_entry_time > expected_exit_time
  end
end
