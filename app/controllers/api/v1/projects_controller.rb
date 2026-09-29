class Api::V1::ProjectsController < Api::BaseController
  # GET /api/v1/projects
  def index
    render json: Project.order(:position).map { |p| project_json(p) }
  end

  # POST /api/v1/projects
  def create
    project = Project.create!(project_params.merge(position: (Project.maximum(:position) || 0) + 1))
    render json: project_json(project), status: :created
  end

  # GET /api/v1/projects/:id — includes headings + all untrashed tasks
  def show
    project = Project.find(params[:id])
    render json: project_json(project).merge(
      headings: project.headings.map { |h| { id: h.id, name: h.name } },
      tasks: project.tasks.untrashed.ordered.includes(:tags, :checklist_items).map(&:serializable),
    )
  end

  # PATCH /api/v1/projects/:id
  def update
    project = Project.find(params[:id])
    project.update!(project_params)
    render json: project_json(project)
  end

  # DELETE /api/v1/projects/:id — real delete, cascades tasks
  def destroy
    Project.find(params[:id]).destroy!
    head :no_content
  end

  private

  def project_params
    attrs = params.permit(:name, :color, :notes, :area_id, :archived)
    attrs[:area_id] = nil if attrs[:area_id] == ""
    attrs
  end

  def project_json(project)
    {
      id: project.id, name: project.name, color: project.color, notes: project.notes,
      archived: project.archived, area_id: project.area_id,
      open_count: project.open_task_count,
      total_count: project.tasks.untrashed.count,
    }
  end
end
