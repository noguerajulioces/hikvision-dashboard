# == Schema Information
#
# Table name: employees
#
#  id               :integer          not null, primary key
#  email            :string
#  first_name       :string
#  hire_date        :date
#  last_name        :string
#  phone            :string
#  role             :string
#  termination_date :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  group_id         :integer
#
class Employee < ApplicationRecord
  belongs_to :group, optional: true
  has_many :attendance_records, dependent: :destroy
  has_many :overtime_records, dependent: :destroy
  has_many :incidents, dependent: :destroy
  has_many :absences, dependent: :destroy

  validates :first_name, :last_name, :role, presence: true
  validates :hire_date, presence: true
  validates :email, uniqueness: true, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, allow_blank: true, length: { minimum: 10, maximum: 15 }

  def self.margin_of_tolerance
    5.minutes
  end

  # Verificar si el empleado tiene una licencia en una fecha específica
  def on_leave?(date)
    absences.exists?([ "start_date <= ? AND end_date >= ?", date, date ])
  end

  # Método para obtener el nombre completo del empleado
  def full_name
    "#{first_name} #{last_name}"
  end
end
