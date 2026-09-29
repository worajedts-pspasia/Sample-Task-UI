class Api::V1::SearchController < Api::BaseController
  # GET /api/v1/search?q=…
  def show
    q = params[:q].to_s.strip
    return render(json: { tasks: [], projects: [], areas: [], tags: [] }) if q.length < 1

    like = "%#{q}%"
    render json: {
      tasks: task_scope.untrashed.open
        .where("tasks.title LIKE :q OR tasks.notes LIKE :q", q: like)
        .order(:position).limit(15)
        .map { |t| { id: t.id, title: t.title, project_id: t.project_id, area_id: t.area_id, when_date: t.when_date&.iso8601 } },
      projects: Project.where("name LIKE :q", q: like).limit(5).map { |p| { id: p.id, name: p.name } },
      areas: Area.where("name LIKE :q", q: like).limit(5).map { |a| { id: a.id, name: a.name } },
      tags: Tag.where("name LIKE :q", q: like).limit(5).map { |t| { id: t.id, name: t.name } },
    }
  end
end
