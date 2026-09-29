class Api::V1::TasksController < Api::BaseController
  before_action :set_task, only: [:show, :update, :destroy, :complete, :uncomplete, :cancel, :schedule, :deadline, :remind, :move, :reorder, :restore]

  BUCKETS = %w[today inbox upcoming anytime someday logbook trash].freeze

  # GET /api/v1/tasks?bucket=today
  def index
    scope =
      case params[:bucket]
      when "today" then task_scope.today
      when "inbox" then task_scope.untrashed.open.inbox.not_someday.where(when_date: nil)
      when "upcoming" then task_scope.upcoming
      when "anytime" then task_scope.anytime
      when "someday" then task_scope.bucket_someday
      when "logbook" then task_scope.logbook.untrashed.order(completed_at: :desc)
      when "trash" then task_scope.trashed.order(trashed_at: :desc)
      else return render(json: { error: "unknown_bucket", allowed: BUCKETS }, status: :bad_request)
      end
    render json: scope.includes(:tags, :checklist_items, :project, :area).ordered.map(&:serializable)
  end

  # GET /api/v1/tasks/:id
  def show
    render json: @task.serializable
  end

  # POST /api/v1/tasks
  def create
    @task = task_scope.create!(task_params.merge(position: next_position))
    apply_tag_ids if params.key?(:tag_ids)
    render json: @task.reload.serializable, status: :created
  end

  # PATCH /api/v1/tasks/:id — direct attribute edits (title, notes, evening, tags…)
  def update
    @task.update!(task_params)
    apply_tag_ids if params.key?(:tag_ids)
    render json: @task.reload.serializable
  end

  # DELETE /api/v1/tasks/:id — moves to Trash
  def destroy
    @task.update!(trashed_at: Time.current)
    render json: @task.serializable
  end

  # POST /api/v1/tasks/:id/complete
  def complete
    @task.update!(status: :completed, completed_at: Time.current)
    render json: @task.serializable
  end

  # POST /api/v1/tasks/:id/uncomplete
  def uncomplete
    @task.update!(status: :open, completed_at: nil)
    render json: @task.serializable
  end

  # POST /api/v1/tasks/:id/cancel
  def cancel
    @task.update!(status: :canceled, completed_at: Time.current)
    render json: @task.serializable
  end

  # POST /api/v1/tasks/:id/schedule
  # body: { when_date: "2026-09-29" } | { evening: true/false } | { someday: true } | { clear: true }
  def schedule
    if params[:clear]
      @task.update!(when_date: nil, evening: false, someday: false)
    elsif params[:someday]
      @task.update!(when_date: nil, someday: true, evening: false)
    elsif params.key?(:evening) && !params.key?(:when_date)
      @task.update!(evening: ActiveModel::Type::Boolean.new.cast(params[:evening]) || false)
    else
      evening = ActiveModel::Type::Boolean.new.cast(params[:evening]) || false
      @task.update!(when_date: params[:when_date], evening: evening, someday: false)
    end
    render json: @task.reload.serializable
  end

  # POST /api/v1/tasks/:id/deadline — { deadline_date: "2026-10-09" | null }
  def deadline
    @task.update!(deadline_date: params[:deadline_date])
    render json: @task.reload.serializable
  end

  # POST /api/v1/tasks/:id/remind — { reminder_at: "09:00" | null }
  def remind
    @task.update!(reminder_at: params[:reminder_at])
    render json: @task.reload.serializable
  end

  # POST /api/v1/tasks/:id/move — { project_id | area_id | inbox: true, heading_id? }
  def move
    attrs = {}
    if ActiveModel::Type::Boolean.new.cast(params[:inbox])
      attrs = { project_id: nil, area_id: nil, heading_id: nil }
    elsif params.key?(:project_id)
      attrs = { project_id: params[:project_id], area_id: nil, heading_id: params[:heading_id] }
    elsif params.key?(:area_id)
      attrs = { project_id: nil, heading_id: nil, area_id: params[:area_id] }
    end
    @task.update!(attrs)
    render json: @task.reload.serializable
  end

  # POST /api/v1/tasks/:id/reorder — { position: 3 }
  def reorder
    @task.update!(position: params.require(:position))
    render json: @task.serializable
  end

  # POST /api/v1/tasks/:id/restore — out of Trash
  def restore
    @task.update!(trashed_at: nil)
    render json: @task.serializable
  end

  # POST /api/v1/tasks/complete_all?bucket=today
  def complete_all
    scope = params[:bucket] == "today" ? task_scope.today : none
    scope.update_all(status: Task.statuses[:completed], completed_at: Time.current)
    head :no_content
  end

  private

  def set_task
    @task = task_scope.find(params[:id])
  end

  def task_params
    permitted = params.permit(:title, :notes, :when_date, :reminder_at, :evening, :deadline_date, :project_id, :area_id, :heading_id, :someday)
    permitted.transform_values { |v| v == "" ? nil : v }
  end

  def apply_tag_ids
    ids = Array(params[:tag_ids]).map(&:to_i)
    @task.taggings.where.not(tag_id: ids).destroy_all
    ids.each { |id| @task.taggings.find_or_create_by!(tag_id: id) if Tag.exists?(id) }
  end

  def next_position
    (task_scope.maximum(:position) || 0) + 1
  end
end
