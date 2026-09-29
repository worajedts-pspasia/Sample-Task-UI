class Api::V1::ChecklistItemsController < Api::BaseController
  before_action :set_task
  before_action :set_item, only: [:update, :destroy]

  # POST /api/v1/tasks/:task_id/checklist_items
  def create
    item = @task.checklist_items.create!(
      title: params.require(:title),
      position: @task.checklist_items.maximum(:position).to_i + 1,
    )
    render json: item.serializable_item, status: :created
  end

  # PATCH /api/v1/tasks/:task_id/checklist_items/:id
  def update
    @item.update!(params.permit(:title, :completed))
    render json: @item.serializable_item
  end

  # DELETE /api/v1/tasks/:task_id/checklist_items/:id
  def destroy
    @item.destroy!
    head :no_content
  end

  private

  def set_task
    @task = task_scope.find(params[:task_id])
  end

  def set_item
    @item = @task.checklist_items.find(params[:id])
  end
end
