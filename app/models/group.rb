# == Schema Information
#
# Table name: groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Group < ApplicationRecord
  has_many :employees, dependent: :nullify
  has_many :schedules, dependent: :destroy

  validates :name, presence: true
end
