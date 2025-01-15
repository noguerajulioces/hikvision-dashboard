# == Schema Information
#
# Table name: incidents
#
#  id          :integer          not null, primary key
#  date        :date
#  issue       :string
#  resolved    :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  employee_id :integer
#
require "test_helper"

class IncidentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
