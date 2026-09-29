module Settings
  class PreferencesController < ApplicationController
    layout "hotwire"

    def edit
      @user = current_user
    end

    def update
      current_user.update!(params.require(:user).permit(:locale))
      redirect_to settings_root_path, notice: t("settings.saved")
    end
  end
end
