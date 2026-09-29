class Api::V1::HeadingsController < Api::BaseController
  def create
    project = Project.find(params[:project_id])
    heading = project.headings.create!(
      name: params.require(:name),
      position: project.headings.maximum(:position).to_i + 1,
    )
    render json: { id: heading.id, name: heading.name }, status: :created
  end

  def update
    heading = Heading.find(params[:id])
    heading.update!(params.permit(:name))
    render json: { id: heading.id, name: heading.name }
  end

  def destroy
    Heading.find(params[:id]).destroy!
    head :no_content
  end
end
