class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :index, :update]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    if current_user and not current_user.admin and not @user.activated
      flash[:danger] = "User #{@user.id} still needs to be activated"
      redirect_to users_url and return
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Your account has been created and requires activation. Please check your email to activate your account."
      redirect_to login_url
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User #{params[:id]} is deleted"
    redirect_to users_url
  end

  def edit
    @user = User.find(params[:id])
  end

  def index
    if current_user.admin
      @users = User.paginate(page: params[:page])
    else
      @users = User.where(activated: true).paginate(page: params[:page])
    end
  end

  def update
    @user = User.find(params[:id])    
    if @user.update_attributes(user_params)
      flash[:success] = "Your details have been saved."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end


    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      unless current_user and current_user.admin?
        flash[:danger] = "Only admins can access this"
        redirect_to(current_user ? root_url : login_url)
      end
    end
end
