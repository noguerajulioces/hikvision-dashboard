# == Schema Information
#
# Table name: employees
#
#  id         :integer          not null, primary key
#  first_name :string
#  hire_date  :date
#  last_name  :string
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer
#
class Employee < ApplicationRecord
  belongs_to :group, optional: true
  has_many :attendance_records, dependent: :destroy
  has_many :overtime_records, dependent: :destroy
  has_many :incidents, dependent: :destroy

  validates :first_name, :last_name, :role, presence: true
  validates :hire_date, presence: true
end
