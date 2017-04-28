module Spina
  module Admin
    class UsersController < AdminController
      before_action :set_breadcrumbs

      authorize_resource class: User

      def index
        @users = User.all
      end

      def new
        @user = User.new
        add_breadcrumb I18n.t('spina.users.new')
      end

      def create
        @user = User.new(user_params)
        add_breadcrumb I18n.t('spina.users.new')
        if @user.save
          redirect_to admin_users_url
        else
          flash.now[:alert] = I18n.t('spina.users.cannot_be_created')
          render :new
        end
      end

      def edit
        @user = User.find(params[:id])
        add_breadcrumb "#{@user}"
      end

      def update
        @user = User.find(params[:id])
        add_breadcrumb "#{@user}"
        if @user.update_attributes(user_params)
          redirect_to spina.admin_users_url
        else
          flash.now[:alert] = I18n.t('spina.users.cannot_be_created')
          render :edit
        end
      end

      def destroy
        @user = User.find(params[:id])
        @user.destroy unless @user == current_user
        redirect_to admin_users_url
      end

      private

      def set_breadcrumbs
        add_breadcrumb I18n.t('spina.preferences.users'), spina.admin_users_path
      end

      def user_params
        params.require(:user).permit(:admin, :email, :name, :password_digest, :password, :password_confirmation, :last_logged_in, :financial_institution_name, :financial_institution_code, :branch_name, :branch_code, :account_type, :account_number, :recipient_name, :memo)
      end

    end
  end
end
