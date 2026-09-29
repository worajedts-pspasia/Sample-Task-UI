module Settings
  class AccountsController < ApplicationController
    layout "hotwire"

    def show
      @user = current_user
    end
  end
end
