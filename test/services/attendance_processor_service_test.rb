require "test_helper"

class AttendanceProcessorServiceTest < ActiveSupport::TestCase
  setup do
    # Nombre real del grupo en producción: la detección debe funcionar por inclusión.
    @sereno = Employee.create!(
      document_number: "3489327",
      first_name: "DIOSNEL",
      last_name: "VILLAR",
      group: Group.create!(name: "Sereno - Diosnel")
    )
  end

  test "pairs an evening entry with the next morning exit" do
    punch "2026-06-19", "19:52:00"
    punch "2026-06-20", "03:59:00"

    process

    record = records.sole
    assert_equal at("2026-06-19 19:52:00"), record.entry_time
    assert_equal at("2026-06-20 03:59:00"), record.exit_time
    assert_equal 0, Event.where(processed: false).count
  end

  test "a day-off morning exit never becomes an entry" do
    # Secuencia real: trabaja viernes a la noche, libra el sábado, vuelve el domingo.
    punch "2026-06-19", "19:54:34"
    punch "2026-06-20", "03:59:15"
    punch "2026-06-21", "19:55:09"
    punch "2026-06-22", "04:59:56"

    process

    assert_equal 2, records.count
    assert records.all? { |record| record.exit_time.present? },
           "la salida matinal del día libre generó un registro espurio sin salida"
  end

  test "a trailing entry stays pending until the next import brings its exit" do
    entry = punch "2026-06-19", "19:52:00"

    process

    assert_empty records
    assert_not entry.reload.processed

    punch "2026-06-20", "03:59:00"
    process

    assert_equal at("2026-06-20 03:59:00"), records.sole.exit_time
    assert_equal 0, Event.where(processed: false).count
  end

  test "a missed exit closes the shift without exit and the next shift pairs normally" do
    punch "2026-06-19", "19:52:00"
    punch "2026-06-20", "19:55:00"
    punch "2026-06-21", "03:58:00"

    process

    assert_equal 2, records.count
    assert_nil records.find_by(entry_time: at("2026-06-19 19:52:00")).exit_time
    assert_equal at("2026-06-21 03:58:00"),
                 records.find_by(entry_time: at("2026-06-20 19:55:00")).exit_time
  end

  test "re-punches collapse into a single shift" do
    punch "2026-06-19", "19:50:00"
    punch "2026-06-19", "19:52:00"
    punch "2026-06-20", "03:59:00"

    process

    record = records.sole
    assert_equal at("2026-06-19 19:50:00"), record.entry_time
    assert_equal at("2026-06-20 03:59:00"), record.exit_time
    assert_equal 0, Event.where(processed: false).count
  end

  test "a trailing cluster of re-punches stays pending" do
    punch "2026-06-19", "19:50:00"
    punch "2026-06-19", "19:52:00"

    process

    assert_empty records
    assert_equal 2, Event.where(processed: false).count
  end

  test "reprocessing an entry never erases the exit of an existing record" do
    entry = punch "2026-06-19", "19:52:00"
    punch "2026-06-20", "03:59:00"
    process

    # Simula una re-importación parcial: la entrada vuelve a quedar sin procesar
    # y el siguiente evento visible está a más de 14 horas.
    entry.update!(processed: false)
    punch "2026-06-22", "19:55:00"
    process

    record = records.find_by(entry_time: at("2026-06-19 19:52:00"))
    assert_equal at("2026-06-20 03:59:00"), record.exit_time
    assert entry.reload.processed
  end

  test "standard employees keep first-entry/last-exit pairing" do
    worker = Employee.create!(document_number: "5058650", group: Group.create!(name: "Ventas"))
    punch "2026-06-19", "07:00:00", employee: worker
    punch "2026-06-19", "12:00:00", employee: worker
    punch "2026-06-19", "16:00:00", employee: worker

    process

    record = worker.attendance_records.reload.sole
    assert_equal at("2026-06-19 07:00:00"), record.entry_time
    assert_equal at("2026-06-19 16:00:00"), record.exit_time
  end

  test "mid-day re-punches are consumed by the day's record and never resurface" do
    # Caso real: entrada 04:02 y dos golpes al salir (14:25 y 14:30). El golpe
    # intermedio quedaba pendiente y la siguiente corrida lo convertía en un
    # registro basura "14:25 sin salida".
    worker = Employee.create!(document_number: "7138042", group: Group.create!(name: "Ventas"))
    punch "2026-06-24", "04:02:08", employee: worker
    punch "2026-06-24", "14:25:17", employee: worker
    punch "2026-06-24", "14:30:52", employee: worker

    process
    assert_equal 0, Event.where(processed: false).count

    process
    record = worker.attendance_records.reload.sole
    assert_equal at("2026-06-24 04:02:08"), record.entry_time
    assert_equal at("2026-06-24 14:30:52"), record.exit_time
  end

  test "standard employees get no exit when the day spans less than 5 hours" do
    worker = Employee.create!(document_number: "5058650", group: Group.create!(name: "Ventas"))
    punch "2026-06-19", "07:00:00", employee: worker
    punch "2026-06-19", "09:00:00", employee: worker

    process

    assert_nil worker.attendance_records.reload.sole.exit_time
  end

  private
    def punch(date, time, employee: @sereno)
      Event.create!(
        employee: employee,
        s_job_no: employee.document_number,
        date: date,
        time: time,
        in_out: "IN"
      )
    end

    def process
      AttendanceProcessorService.new.call
    end

    def records
      @sereno.attendance_records.reload
    end

    def at(datetime)
      Time.zone.parse(datetime)
    end
end
