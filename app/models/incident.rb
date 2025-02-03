# == Schema Information
#
# Table name: incidents
#
#  id          :bigint           not null, primary key
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

  after_initialize :set_default_resolved, if: :new_record?

  default_scope -> { order(created_at: :asc) }

  private

  def set_default_resolved
    self.resolved = false if resolved.nil?
  end
end
