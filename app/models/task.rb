class Task < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true
  belongs_to :area, optional: true
  belongs_to :heading, optional: true
  has_many :checklist_items, -> { order(:position) }, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  enum :status, { open: 0, completed: 1, canceled: 2 }

  validates :title, presence: true
  validates :status, presence: true

  scope :ordered, -> { order(:position, :id) }
  scope :untrashed, -> { where(trashed_at: nil) }
  scope :trashed, -> { where.not(trashed_at: nil) }
  scope :scheduled, -> { where.not(when_date: nil) }
  scope :someday, -> { where(someday: true) }
  scope :not_someday, -> { where(someday: false) }
  scope :inbox, -> { where(project_id: nil, area_id: nil) }
  scope :logbook, -> { where(status: [:completed, :canceled]) }

  # Today = everything scheduled for today or earlier (overdue included)
  # plus anything with a deadline today or overdue.
  scope :today, -> {
    untrashed.open.where("when_date <= :today OR deadline_date <= :today", today: Date.current)
  }

  scope :upcoming, -> {
    untrashed.open.scheduled.where("when_date > :today", today: Date.current)
      .or(untrashed.open.where("deadline_date > :today", today: Date.current))
  }

  scope :anytime, -> { untrashed.open.not_someday }
  scope :bucket_someday, -> { untrashed.open.someday }

  def serializable
    {
      id: id,
      title: title,
      notes: notes,
      when_date: when_date&.iso8601,
      reminder_at: reminder_at&.strftime("%H:%M"),
      evening: evening,
      deadline_date: deadline_date&.iso8601,
      status: status,
      someday: someday,
      trashed: trashed_at.present?,
      completed_at: completed_at&.iso8601,
      position: position,
      project_id: project_id,
      area_id: area_id,
      heading_id: heading_id,
      tags: tags.order(:name).map { |t| { id: t.id, name: t.name } },
      checklist_items: checklist_items.map { |c| { id: c.id, title: c.title, completed: c.completed } },
    }
  end
end
