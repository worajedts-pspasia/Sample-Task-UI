class Api::V1::TagsController < Api::BaseController
  def index
    render json: Tag.order(:name).map { |t| tag_json(t) }
  end

  def create
    tag = Tag.create!(tag_params)
    render json: tag_json(tag), status: :created
  end

  def update
    tag = Tag.find(params[:id])
    tag.update!(tag_params)
    render json: tag_json(tag)
  end

  def destroy
    Tag.find(params[:id]).destroy!
    head :no_content
  end

  private

  def tag_params
    params.permit(:name, :parent_id)
  end

  def tag_json(tag)
    { id: tag.id, name: tag.name, parent_id: tag.parent_id }
  end
end
