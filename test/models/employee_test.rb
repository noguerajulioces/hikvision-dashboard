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
  test "sereno? detects any group containing sereno, like the production name" do
    assert Employee.new(group: Group.create!(name: "Sereno")).sereno?
    assert Employee.new(group: Group.create!(name: "Sereno - Diosnel")).sereno?
    assert Employee.new(group: Group.create!(name: "SERENOS")).sereno?
  end

  test "sereno? is false for other groups and for employees without group" do
    assert_not Employee.new(group: Group.create!(name: "Ventas")).sereno?
    assert_not Employee.new.sereno?
  end
end
