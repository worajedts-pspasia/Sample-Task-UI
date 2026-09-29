class Api::V1::TrashController < Api::BaseController
  # DELETE /api/v1/trash/empty
  def empty
    task_scope.trashed.destroy_all
    head :no_content
  end
end
