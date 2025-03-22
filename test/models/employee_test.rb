# == Schema Information
#
# Table name: employees
#
#  id               :bigint           not null, primary key
#  deleted_at       :datetime
#  document_number  :string
#  email            :string
#  first_name       :string
#  hire_date        :date
#  last_name        :string
#  phone            :string
#  termination_date :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  group_id         :integer
#
# Indexes
#
#  index_employees_on_deleted_at  (deleted_at)
#
require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
