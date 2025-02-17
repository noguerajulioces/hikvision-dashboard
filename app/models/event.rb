# == Schema Information
#
# Table name: events
#
#  id                :bigint           not null, primary key
#  attendance_status :string
#  date              :date
#  event_main_code   :integer
#  event_sub_code    :integer
#  in_out            :string
#  s_card            :string
#  s_job_no          :string
#  s_name            :string
#  serial_no         :integer
#  time              :time
#  wear_mask         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  device_id         :bigint
#  employee_id       :bigint
#  read_id           :integer
#
# Indexes
#
#  index_events_on_device_id    (device_id)
#  index_events_on_employee_id  (employee_id)
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#  fk_rails_...  (employee_id => employees.id)
#
require "csv"

class Event < ApplicationRecord
  belongs_to :device, optional: true
  belongs_to :employee, optional: true

  validates :date, :time, :in_out, presence: true

  before_validation :assign_employee
  before_create :clean_params

  default_scope { order(date: :desc, time: :asc) }

  def self.import_from_csv(file_path)
    CSV.foreach(file_path, headers: true, encoding: "bom|utf-8") do |row|
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
        employee: Employee.find_by(document_number: row["sCard"]) # Asignar empleado basado en la tarjeta
      )
    end
  end

  private

  def clean_params
    self.s_job_no = s_job_no.delete_prefix("'") if s_job_no.present?
    self.s_card = s_card.delete_prefix("'") if s_card.present?
  end

  def assign_employee
    s_job_no = self.s_job_no.delete_prefix("'") if self.s_job_no.present?
    if s_job_no.present?
      self.employee = Employee.find_or_create_by!(document_number: s_job_no)
    end
  end
end
