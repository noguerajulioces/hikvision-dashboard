# == Schema Information
#
# Table name: schedules
#
#  id                  :integer          not null, primary key
#  day_of_week         :string
#  expected_entry_time :time
#  expected_exit_time  :time
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :integer
#
class Schedule < ApplicationRecord
  belongs_to :group

  validates :day_of_week, :expected_entry_time, :expected_exit_time, presence: true
end
