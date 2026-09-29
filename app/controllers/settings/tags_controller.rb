module Settings
  class TagsController < ApplicationController
    layout "hotwire"

    def index
      @tags = Tag.order(:name)
      @tag = Tag.new
    end

    def create
      Tag.create!(params.require(:tag).permit(:name))
      redirect_to tags_path, notice: "Tag created."
    end

    def update
      Tag.find(params[:id]).update!(params.require(:tag).permit(:name))
      redirect_to tags_path, notice: "Tag renamed."
    end

    def destroy
      Tag.find(params[:id]).destroy!
      redirect_to tags_path, notice: "Tag deleted."
    end
  end
end
