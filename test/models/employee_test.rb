# == Schema Information
#
# Table name: employees
#
#  id               :integer          not null, primary key
#  first_name       :string
#  hire_date        :date
#  last_name        :string
#  role             :string
#  termination_date :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  group_id         :integer
#
require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
