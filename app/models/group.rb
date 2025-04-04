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
  has_and_belongs_to_many :employees
  has_many :schedules, dependent: :destroy

  accepts_nested_attributes_for :schedules, allow_destroy: true

  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "name", "updated_at" ]
  end
end
