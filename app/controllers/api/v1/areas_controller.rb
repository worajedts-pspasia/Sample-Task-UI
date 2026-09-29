class Api::V1::AreasController < Api::BaseController
  def index
    render json: Area.order(:position).map { |a| area_json(a) }
  end

  def create
    area = Area.create!(area_params.merge(position: (Area.maximum(:position) || 0) + 1))
    render json: area_json(area), status: :created
  end

  def show
    render json: area_json(Area.find(params[:id])).merge(
      tasks: Area.find(params[:id]).tasks.untrashed.ordered.includes(:tags, :checklist_items).map(&:serializable),
    )
  end

  def update
    area = Area.find(params[:id])
    area.update!(area_params)
    render json: area_json(area)
  end

  def destroy
    Area.find(params[:id]).destroy! # nullifies tasks/projects
    head :no_content
  end

  private

  def area_params
    params.permit(:name)
  end

  def area_json(area)
    { id: area.id, name: area.name, open_count: area.open_task_count }
  end
end
