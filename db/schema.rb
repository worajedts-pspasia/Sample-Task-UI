# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_28_115401) do
  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checklist_items", force: :cascade do |t|
    t.integer "task_id", null: false
    t.string "title", null: false
    t.boolean "completed", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_checklist_items_on_task_id"
  end

  create_table "headings", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_headings_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer "area_id"
    t.string "name", null: false
    t.string "color", default: "#4a7cf5", null: false
    t.text "notes"
    t.boolean "archived", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_projects_on_area_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "task_id"], name: "index_taggings_on_tag_id_and_task_id", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["task_id"], name: "index_taggings_on_task_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_tags_on_parent_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id"
    t.integer "area_id"
    t.integer "heading_id"
    t.string "title", null: false
    t.text "notes"
    t.date "when_date"
    t.time "reminder_at"
    t.boolean "evening", default: false, null: false
    t.date "deadline_date"
    t.integer "status", default: 0, null: false
    t.datetime "trashed_at"
    t.datetime "completed_at"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "someday", default: false, null: false
    t.index ["area_id"], name: "index_tasks_on_area_id"
    t.index ["heading_id"], name: "index_tasks_on_heading_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "api_token", null: false
    t.string "locale", default: "en", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "checklist_items", "tasks", on_delete: :cascade
  add_foreign_key "headings", "projects", on_delete: :cascade
  add_foreign_key "projects", "areas"
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "taggings", "tasks", on_delete: :cascade
  add_foreign_key "tags", "tags", column: "parent_id"
  add_foreign_key "tasks", "areas", on_delete: :nullify
  add_foreign_key "tasks", "headings", on_delete: :nullify
  add_foreign_key "tasks", "projects", on_delete: :nullify
  add_foreign_key "tasks", "users"
end
