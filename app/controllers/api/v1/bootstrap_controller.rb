class Api::V1::BootstrapController < Api::BaseController
  # GET /api/v1/bootstrap — everything the SPA shell needs on boot.
  def show
    projects = Project.includes(:area).order(:position)
    render json: {
      user: {
        email: current_user.email,
        locale: current_user.locale,
        api_token: current_user.api_token,
      },
      areas: Area.order(:position).map { |a| { id: a.id, name: a.name } },
      projects: projects.map do |p|
        {
          id: p.id, name: p.name, color: p.color, notes: p.notes,
          archived: p.archived, area_id: p.area_id,
          open_count: p.open_task_count,
          total_count: p.tasks.untrashed.count,
        }
      end,
      tags: Tag.order(:name).map { |t| { id: t.id, name: t.name } },
      counts: {
        today: task_scope.today.count,
        inbox: task_scope.untrashed.open.inbox.not_someday.where(when_date: nil).count,
        anytime: task_scope.anytime.count,
        someday: task_scope.bucket_someday.count,
        logbook: task_scope.logbook.count,
        trash: task_scope.trashed.count,
      },
    }
  end
end
