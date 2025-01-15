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
class Incident < ApplicationRecord
  belongs_to :employee

  validates :date, :issue, presence: true
end
