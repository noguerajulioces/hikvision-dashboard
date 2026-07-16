class DedupeEventsAndAddUniqueIndex < ActiveRecord::Migration[8.0]
  def up
    # Re-importar exportaciones con rangos solapados insertaba el mismo golpe varias
    # veces (la tabla no tenía unicidad), y cada duplicado quedaba processed: false,
    # re-disparando el procesamiento de asistencia sobre días ya cerrados.
    # Conservamos una fila por golpe, prefiriendo la ya procesada.
    before = select_value("SELECT COUNT(*) FROM events").to_i

    execute <<~SQL
      DELETE FROM events WHERE id IN (
        SELECT id FROM (
          SELECT id, ROW_NUMBER() OVER (
            PARTITION BY date, time, s_job_no, event_sub_code
            ORDER BY processed DESC, id ASC
          ) AS rn
          FROM events
          WHERE s_job_no IS NOT NULL
        ) WHERE rn > 1
      );
    SQL

    after = select_value("SELECT COUNT(*) FROM events").to_i
    say "Eventos duplicados eliminados: #{before - after}"

    # No incluye serial_no: el dispositivo puede resetearlo al vaciar su log.
    # s_job_no ya se guarda normalizado (Event#clean_params quita el prefijo ').
    # Filas manuales con s_job_no NULL no chocan (SQLite trata cada NULL como distinto).
    add_index :events, [ :date, :time, :s_job_no, :event_sub_code ],
              unique: true, name: "index_events_on_unique_punch"
  end

  def down
    remove_index :events, name: "index_events_on_unique_punch"
  end
end
