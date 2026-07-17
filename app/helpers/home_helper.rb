module HomeHelper
  # Distribución de horarios por turno según la hora local de entrada.
  # Calculado en Ruby para ser portable entre SQLite (escritorio) y Postgres
  # (el strftime anterior era SQLite-only y rompía el dashboard en Postgres).
  def schedule_shift_distribution
    entry_hours = Schedule.joins(:group)
                          .pluck(:expected_entry_time)
                          .compact
                          .map { |time| time.in_time_zone.hour }

    {
      morning: entry_hours.count { |hour| hour.between?(5, 11) },
      afternoon: entry_hours.count { |hour| hour.between?(12, 17) },
      night: entry_hours.count { |hour| hour >= 18 || hour <= 4 }
    }
  end
end
