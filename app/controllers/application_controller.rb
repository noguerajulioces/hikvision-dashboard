class ApplicationController < ActionController::Base
  DEFAULT_PASSWORD = "123456".freeze

  before_action :authenticate_user!
  before_action :require_password_change
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  # El seed crea el admin con una clave conocida: obligar a cambiarla al ingresar.
  def require_password_change
    return unless user_signed_in? && !devise_controller?
    return unless current_user.valid_password?(DEFAULT_PASSWORD)

    redirect_to edit_user_path(current_user), alert: "Por seguridad, cambiá la contraseña predeterminada para continuar."
  end
end
