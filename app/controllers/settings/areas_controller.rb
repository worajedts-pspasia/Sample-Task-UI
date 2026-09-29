module Settings
  class AreasController < ApplicationController
    layout "hotwire"

    before_action :set_area, only: [:edit, :update, :destroy]

    def edit
    end

    def update
      @area.update!(params.require(:area).permit(:name))
      redirect_to edit_settings_area_path(@area), notice: "Area saved."
    end

    def destroy
      @area.destroy!
      redirect_to root_path, notice: "Area deleted."
    end

    private

    def set_area
      @area = Area.find(params[:id])
    end
  end
end
