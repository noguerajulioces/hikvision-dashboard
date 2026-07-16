class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Núcleo de asistencia: se consulta por empleado + rango de entry_time y por estado de procesamiento.
    add_index :attendance_records, [ :employee_id, :entry_time ], if_not_exists: true
    add_index :attendance_records, :device_id, if_not_exists: true
    add_index :attendance_records, :processed, if_not_exists: true

    # Cálculo de nómina/overtime e incidencias por empleado y fecha.
    add_index :overtime_records, [ :employee_id, :date ], if_not_exists: true
    add_index :incidents, [ :employee_id, :date ], if_not_exists: true

    # Listado/join de empleados por grupo.
    add_index :employees, :group_id, if_not_exists: true

    # Orden por defecto de eventos (date/time desc) y procesamiento por fecha.
    add_index :events, [ :date, :time ], if_not_exists: true

    # Consulta de ausencias por empleado y rango (on_leave? / unprocessed_attendance_records).
    add_index :absences, [ :employee_id, :start_date, :end_date ], if_not_exists: true
  end
end
