
class OvertimeCalculator
  def initialize(record, schedule, lunch_time)
    @record = record
    @schedule = schedule
    @lunch_time = lunch_time
  end

  def calculate_overtime_hours
    # Definir el tiempo de tolerancia (5 minutos)
    tolerance = Setting&.margin_of_tolerance || 5

    # Calcular llegada tardía (si la hay)
    late_minutes = [ (@record.entry_time - @schedule.expected_entry_time) / 60.0, 0 ].max

    # Si la llegada tardía está dentro del tiempo de tolerancia, se ignora
    late_minutes = 0 if late_minutes <= (tolerance / 60.0)

    # Verificar si hay horas extra (salida después de la hora esperada)
    return 0 unless @record.exit_time > @schedule.expected_exit_time

    # Calcular horas trabajadas después de la salida esperada
    extra_hours = (@record.exit_time - @schedule.expected_exit_time) / 3600.0

    # Restar el tiempo de llegada tardía (convertido a horas)
    overtime_hours = extra_hours - (late_minutes / 60.0)

    # Descontar tiempo de almuerzo si corresponde
    overtime_hours -= lunch_hours if @lunch_time && overtime_hours > 4

    # Asegurarse de que no sean horas negativas
    [ overtime_hours, 0 ].max
  end

  def create_overtime_record(hours)
    compensation = hours * overtime_rate
    OvertimeRecord.create!(
      employee: @record.employee,
      date: @record.entry_time.to_date,
      hours_worked: hours,
      compensation: compensation
    )
  end

  private

  def lunch_hours
    Setting&.lunch_hours&.to_i || 1
  end

  def overtime_rate
    Setting.overtime_rate
  end
end
