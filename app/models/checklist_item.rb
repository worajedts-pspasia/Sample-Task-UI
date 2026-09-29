class ChecklistItem < ApplicationRecord
  belongs_to :task

  validates :title, presence: true

  def serializable_item
    { id: id, title: title, completed: completed }
  end
end
