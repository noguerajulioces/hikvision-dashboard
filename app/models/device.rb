# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  ip_address :string
#  model      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Device < ApplicationRecord
  has_many :attendance_records, dependent: :nullify

  validates :ip_address, :model, presence: true
end
