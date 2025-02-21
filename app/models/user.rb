# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  active                 :boolean
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  phone                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validate :must_have_at_least_one_role
  validate :cannot_deactivate_last_active_user, on: :update

  def active_for_authentication?
    super && active?
  end

  private

  def must_have_at_least_one_role
    if roles.blank?
      errors.add(:roles, "debe tener al menos un rol asignado.")
    end
  end

  def cannot_deactivate_last_active_user
    # Verifica si se está cambiando el estado de activo a inactivo
    if active_changed?(from: true, to: false)
      # Verifica si es el único usuario activo
      if User.where(active: true).count == 1
        errors.add(:user, "no se puede desactivar porque es el único usuario activo.")
      end
    end
  end
end
