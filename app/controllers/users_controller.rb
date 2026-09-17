class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ edit update destroy change_password update_password login_history ]

  def index
    if current_user.admin?
      @users = User.all.order(:name).page(params[:page]).per(20)
    else
      @user = current_user
    end
  end

  def new
    authorize_admin!
    @user = User.new
  end

  def edit
    authorize_admin!
  end

  def create
    authorize_admin!
    @user = User.new(user_params)

    if @user.save
      @users = User.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Usuario creado exitosamente."

      respond_to do |format|
        format.html { redirect_to users_path, notice: "Usuario creado exitosamente." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize_admin!
    if @user.update(user_params_without_password)
      @users = User.all.order(:name).page(params[:page]).per(20)
      flash.now[:notice] = "Usuario actualizado exitosamente."

      respond_to do |format|
        format.html { redirect_to users_path, notice: "Usuario actualizado exitosamente." }
        format.turbo_stream { render :create } # Reuse the create template which updates the grid
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_admin!
    if @user == current_user
      redirect_to users_path, alert: "No puedes eliminarte a ti mismo."
    else
      @user.destroy
      redirect_to users_path, notice: "Usuario eliminado exitosamente.", status: :see_other
    end
  end

  def change_password
    authorize_user_or_admin!
  end

  def update_password
    authorize_user_or_admin!

    if @user.update(password_params)
      bypass_sign_in(@user) if @user == current_user

      if current_user.admin?
        @users = User.all.order(:name).page(params[:page]).per(20)
      end

      flash.now[:notice] = "Contraseña actualizada exitosamente."
      respond_to do |format|
        format.html { redirect_to users_path, notice: "Contraseña actualizada exitosamente." }
        format.turbo_stream { render :create } # Reuse create to close modal and update (though list doesn't change, flash does)
      end
    else
      render :change_password, status: :unprocessable_entity
    end
  end

  def login_history
    authorize_admin!
    @login_histories = UserLoginHistory.where(user: @user).order(sign_in_at: :desc).page(params[:page]).per(20)
  end

  def global_login_history
    authorize_admin!
    @login_histories = UserLoginHistory.includes(:user).order(sign_in_at: :desc).page(params[:page]).per(20)
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def authorize_admin!
      unless current_user.admin?
        redirect_to users_path, alert: "No autorizado."
      end
    end

    def authorize_user_or_admin!
      unless current_user.admin? || @user == current_user
        redirect_to users_path, alert: "No autorizado."
      end
    end

    def user_params
      params.require(:user).permit(:name, :run, :email, :role, :password, :password_confirmation)
    end

    def user_params_without_password
      params.require(:user).permit(:name, :run, :email, :role)
    end

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
