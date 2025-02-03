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
class OvertimeRecord < ApplicationRecord
  belongs_to :employee

  validates :date, :hours_worked, :compensation, presence: true
end
