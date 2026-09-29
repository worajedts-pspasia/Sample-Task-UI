class Tag < ApplicationRecord
  belongs_to :parent, class_name: "Tag", optional: true
  has_many :taggings, dependent: :destroy
  has_many :tasks, through: :taggings

  validates :name, presence: true, uniqueness: true
end
