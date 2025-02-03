# == Schema Information
#
# Table name: overtime_records
#
#  id           :bigint           not null, primary key
#  compensation :decimal(, )
#  date         :date
#  hours_worked :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  employee_id  :integer
#
require "test_helper"

class OvertimeRecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
