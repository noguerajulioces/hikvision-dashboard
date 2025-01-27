# == Schema Information
#
# Table name: payroll_reports
#
#  id                   :integer          not null, primary key
#  comments             :text
#  end_date             :date
#  start_date           :date
#  total_hours_worked   :decimal(15, 2)
#  total_incidents      :integer
#  total_overtime_hours :decimal(15, 2)
#  total_payment        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  employee_id          :integer          not null
#
# Indexes
#
#  index_payroll_reports_on_employee_id  (employee_id)
#
# Foreign Keys
#
#  employee_id  (employee_id => employees.id)
#
require "test_helper"

class PayrollReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
