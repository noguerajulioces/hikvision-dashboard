# == Schema Information
#
# Table name: events
#
#  id                :bigint           not null, primary key
#  s_name            :string
#  s_job_no          :string
#  s_card            :string
#  date              :date
#  time              :time
#  in_out            :string
#  read_id           :integer
#  event_main_code   :integer
#  event_sub_code    :integer
#  attendance_status :string
#  wear_mask         :string
#  serial_no         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  device_id         :integer
#  employee_id       :integer
#
# Indexes
#
#  index_events_on_device_id   (device_id)
#  index_events_on_employee_id (employee_id)
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#  fk_rails_...  (employee_id => employees.id)
#
require 'csv'

class Event < ApplicationRecord
  belongs_to :device, optional: true
  belongs_to :employee, optional: true

  validates :date, :time, :in_out, presence: true

  before_validation :assign_employee

  default_scope { order(date: :desc, time: :asc) }

  def self.import_from_csv(file_path)
    CSV.foreach(file_path, headers: true) do |row|
      create(
        s_name: row["sName"],
        s_job_no: row["sJobNo"],
        s_card: row["sCard"],
        date: row["Date"],
        time: row["Time"],
        in_out: row["IN/OUT"],
        read_id: row["ReadID"],
        event_main_code: row["EventMainCode"],
        event_sub_code: row["EventSubCode"],
        attendance_status: row["AttendanceStatus"],
        wear_mask: row["WearMask"],
        serial_no: row["SerialNo"],
        employee: Employee.find_by(card_number: row["sCard"]) # Asignar empleado basado en la tarjeta
      )
    end
  end

  private

  def assign_employee
    self.employee = Employee.find_by(card_number: s_card) if s_card.present?
  end
end
