require "rails_helper"

RSpec.describe "Api::V1::Tasks", type: :request, openapi: true do
  before { api_sign_in }

  describe "GET /api/v1/tasks" do
    before do
      @user.tasks.create!(title: "Scheduled today", when_date: Date.current, position: 1)
      @user.tasks.create!(title: "Inbox item", position: 2)
      @user.tasks.create!(title: "Someday item", someday: true, position: 3)
      @user.tasks.create!(title: "Future", when_date: Date.current + 5, position: 4)
      @done = @user.tasks.create!(title: "Done", status: :completed, completed_at: 1.day.ago, position: 5)
    end

    it "lists today" do
      get "/api/v1/tasks", params: { bucket: "today" }, headers: @headers
      expect(response).to have_http_status(:ok)
      titles = response.parsed_body.map { |t| t["title"] }
      expect(titles).to include("Scheduled today")
      expect(titles).not_to include("Inbox item", "Future", "Done")
    end

    it "lists inbox" do
      get "/api/v1/tasks", params: { bucket: "inbox" }, headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |t| t["title"] }).to eq(["Inbox item"])
    end

    it "lists logbook" do
      get "/api/v1/tasks", params: { bucket: "logbook" }, headers: @headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.first["title"]).to eq("Done")
    end

    it "rejects unknown buckets" do
      get "/api/v1/tasks", params: { bucket: "nope" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "POST /api/v1/tasks" do
    it "creates a task with tags" do
      tag = Tag.create!(name: "Work")
      post "/api/v1/tasks", params: { title: "New task", when_date: Date.current.iso8601, tag_ids: [tag.id] }, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["title"]).to eq("New task")
      expect(body["tags"].first["name"]).to eq("Work")
    end

    it "validates title" do
      post "/api/v1/tasks", params: { title: "" }, headers: @headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "task actions" do
    let(:task) { @user.tasks.create!(title: "Actionable", position: 1) }

    it "completes and uncompletes" do
      post "/api/v1/tasks/#{task.id}/complete", headers: @headers
      expect(response.parsed_body["status"]).to eq("completed")
      post "/api/v1/tasks/#{task.id}/uncomplete", headers: @headers
      expect(response.parsed_body["status"]).to eq("open")
    end

    it "schedules" do
      post "/api/v1/tasks/#{task.id}/schedule", params: { when_date: (Date.current + 1).iso8601 }, headers: @headers, as: :json
      expect(response.parsed_body["when_date"]).to eq((Date.current + 1).iso8601)
    end

    it "moves to someday via schedule" do
      post "/api/v1/tasks/#{task.id}/schedule", params: { someday: true }, headers: @headers, as: :json
      expect(response.parsed_body["someday"]).to be(true)
    end

    it "sets and clears a deadline" do
      post "/api/v1/tasks/#{task.id}/deadline", params: { deadline_date: "2026-10-09" }, headers: @headers, as: :json
      expect(response.parsed_body["deadline_date"]).to eq("2026-10-09")
      post "/api/v1/tasks/#{task.id}/deadline", params: { deadline_date: nil }, headers: @headers, as: :json
      expect(response.parsed_body["deadline_date"]).to be_nil
    end

    it "sets a reminder" do
      post "/api/v1/tasks/#{task.id}/remind", params: { reminder_at: "09:00" }, headers: @headers, as: :json
      expect(response.parsed_body["reminder_at"]).to eq("09:00")
    end

    it "moves to a project" do
      project = Project.create!(name: "P", color: "#4a7cf5")
      post "/api/v1/tasks/#{task.id}/move", params: { project_id: project.id }, headers: @headers, as: :json
      expect(response.parsed_body["project_id"]).to eq(project.id)
    end

    it "soft-deletes to trash and restores" do
      delete "/api/v1/tasks/#{task.id}", headers: @headers
      expect(response.parsed_body["trashed"]).to be(true)
      post "/api/v1/tasks/#{task.id}/restore", headers: @headers
      expect(response.parsed_body["trashed"]).to be(false)
    end
  end

  describe "checklist items" do
    let(:task) { @user.tasks.create!(title: "With checklist", position: 1) }

    it "creates, updates, destroys" do
      post "/api/v1/tasks/#{task.id}/checklist_items", params: { title: "Step" }, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      item_id = response.parsed_body["id"]
      patch "/api/v1/tasks/#{task.id}/checklist_items/#{item_id}", params: { completed: true }, headers: @headers, as: :json
      expect(response.parsed_body["completed"]).to be(true)
      delete "/api/v1/tasks/#{task.id}/checklist_items/#{item_id}", headers: @headers
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/v1/tasks/complete_all" do
    it "completes the today bucket" do
      @user.tasks.create!(title: "A", when_date: Date.current, position: 1)
      @user.tasks.create!(title: "B", when_date: Date.current, position: 2)
      post "/api/v1/tasks/complete_all", params: { bucket: "today" }, headers: @headers, as: :json
      expect(response).to have_http_status(:no_content)
      expect(@user.tasks.today.count).to eq(0)
    end
  end

  describe "DELETE /api/v1/trash/empty" do
    it "destroys trashed tasks" do
      @user.tasks.create!(title: "Gone", trashed_at: Time.current, position: 1)
      delete "/api/v1/trash/empty", headers: @headers
      expect(response).to have_http_status(:no_content)
      expect(@user.tasks.trashed.count).to eq(0)
    end
  end

  describe "authentication" do
    it "rejects missing credentials" do
      get "/api/v1/tasks", params: { bucket: "today" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
