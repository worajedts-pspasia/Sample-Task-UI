class CreateCoreSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :api_token, null: false, index: { unique: true }
      t.string :locale, null: false, default: "en"
      t.timestamps
    end

    create_table :areas do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :projects do |t|
      t.references :area, null: true, foreign_key: true
      t.string :name, null: false
      t.string :color, null: false, default: "#4a7cf5"
      t.text :notes
      t.boolean :archived, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :headings do |t|
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: true, foreign_key: { on_delete: :nullify }
      t.references :area, null: true, foreign_key: { on_delete: :nullify }
      t.references :heading, null: true, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.text :notes
      t.date :when_date
      t.time :reminder_at
      t.boolean :evening, null: false, default: false
      t.date :deadline_date
      t.integer :status, null: false, default: 0 # 0 open, 1 completed, 2 canceled
      t.datetime :trashed_at
      t.datetime :completed_at
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :checklist_items do |t|
      t.references :task, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false
      t.boolean :completed, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :tags do |t|
      t.string :name, null: false
      t.references :parent, null: true, foreign_key: { to_table: :tags }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: { on_delete: :cascade }
      t.references :task, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
    add_index :taggings, %i[tag_id task_id], unique: true
  end
end
