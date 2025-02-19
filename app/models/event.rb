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
#  processed         :boolean          default(FALSE)
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

  default_scope { order(date: :desc, time: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    [ "attendance_status", "created_at", "date", "device_id", "employee_id", "event_main_code", "event_sub_code", "id", "in_out", "read_id", "s_card", "s_job_no", "s_name", "serial_no", "time", "updated_at", "wear_mask" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "device", "employee" ]
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
