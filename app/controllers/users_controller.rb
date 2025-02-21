class UsersController < ApplicationController
  before_action :set_user, only: [ :edit, :update, :destroy, :toggle_active ]

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "Usuario creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: "Usuario actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "Usuario eliminado exitosamente."
  end

  def toggle_active
    @user.active = !@user.active
    if @user.save
      redirect_to users_path, notice: "El estado del usuario ha sido actualizado."
    else
      # Si falló, muestra el mensaje de error específico
      error_message = @user.errors.full_messages.to_sentence
      redirect_to users_path, alert: "Hubo un error: #{error_message}"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    if action_name == "update"
      params.require(:user).permit(:email, :name, :phone, :active, :role_ids)
    else
      params.require(:user).permit(:email, :name, :password, :password_confirmation, :phone, :active, :role_ids)
    end
  end
end
