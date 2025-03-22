# == Schema Information
#
# Table name: app_settings
#
#  id         :bigint           not null, primary key
#  key        :string
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class AppSettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
