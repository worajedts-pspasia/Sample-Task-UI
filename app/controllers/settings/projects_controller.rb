module Settings
  class ProjectsController < ApplicationController
    layout "hotwire"

    before_action :set_project, only: [:edit, :update, :destroy]

    def edit
    end

    def update
      attrs = params.require(:project).permit(:name, :color, :notes, :area_id)
      attrs[:area_id] = nil if attrs[:area_id].blank?
      @project.update!(attrs)
      redirect_to edit_settings_project_path(@project), notice: "List saved."
    end

    def destroy
      @project.destroy!
      redirect_to root_path, notice: "List deleted."
    end

    private

    def set_project
      @project = Project.find(params[:id])
    end
  end
end
