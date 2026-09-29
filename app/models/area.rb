class Area < ApplicationRecord
  has_many :projects, dependent: :nullify
  has_many :tasks, dependent: :nullify

  validates :name, presence: true

  def open_task_count
    tasks.open.untrashed.count
  end
end
