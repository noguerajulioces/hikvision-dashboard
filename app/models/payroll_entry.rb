# == Schema Information
#
# Table name: payroll_entries
#
#  id              :bigint           not null, primary key
#  recordable_type :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  payroll_id      :bigint           not null
#  recordable_id   :bigint           not null
#
# Indexes
#
#  index_payroll_entries_on_payroll_id  (payroll_id)
#  index_payroll_entries_on_recordable  (recordable_type,recordable_id)
#
# Foreign Keys
#
#  fk_rails_...  (payroll_id => payrolls.id)
#
class PayrollEntry < ApplicationRecord
  belongs_to :payroll
  belongs_to :recordable, polymorphic: true
end
