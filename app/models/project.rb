class Project < ApplicationRecord
  belongs_to :area, optional: true
  has_many :headings, -> { order(:position) }, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/ }

  scope :active, -> { where(archived: false) }

  def open_task_count
    tasks.open.untrashed.where(someday: false).count
  end
end
