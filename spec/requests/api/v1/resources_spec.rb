require "rails_helper"

RSpec.describe "Api::V1 resources", type: :request, openapi: true do
  before { api_sign_in }

  describe "GET /api/v1/bootstrap" do
    it "returns the shell payload" do
      @user.tasks.create!(title: "T", when_date: Date.current, position: 1)
      Project.create!(name: "House", color: "#4a7cf5")
      get "/api/v1/bootstrap", headers: @headers
      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["user"]["email"]).to eq("spec@things.local")
      expect(body["counts"]["today"]).to eq(1)
      expect(body["projects"].first["name"]).to eq("House")
    end
  end

  describe "projects" do
    it "CRUDs" do
      post "/api/v1/projects", params: { name: "New list", color: "#2db8a6" }, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      id = response.parsed_body["id"]
      patch "/api/v1/projects/#{id}", params: { name: "Renamed" }, headers: @headers, as: :json
      expect(response.parsed_body["name"]).to eq("Renamed")
      get "/api/v1/projects/#{id}", headers: @headers
      expect(response.parsed_body["tasks"]).to eq([])
      delete "/api/v1/projects/#{id}", headers: @headers
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "areas" do
    it "CRUDs" do
      post "/api/v1/areas", params: { name: "Personal" }, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      id = response.parsed_body["id"]
      patch "/api/v1/areas/#{id}", params: { name: "Life" }, headers: @headers, as: :json
      expect(response.parsed_body["name"]).to eq("Life")
      delete "/api/v1/areas/#{id}", headers: @headers
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "tags" do
    it "CRUDs" do
      post "/api/v1/tags", params: { name: "Errand" }, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      id = response.parsed_body["id"]
      patch "/api/v1/tags/#{id}", params: { name: "Errands" }, headers: @headers, as: :json
      expect(response.parsed_body["name"]).to eq("Errands")
      delete "/api/v1/tags/#{id}", headers: @headers
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "headings" do
    it "creates under a project" do
      project = Project.create!(name: "P", color: "#4a7cf5")
      post "/api/v1/projects/#{project.id}/headings", params: { name: "Maintenance" }, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["name"]).to eq("Maintenance")
    end
  end

  describe "GET /api/v1/search" do
    it "finds tasks and projects" do
      @user.tasks.create!(title: "Buy groceries", position: 1)
      Project.create!(name: "House shopping", color: "#4a7cf5")
      get "/api/v1/search", params: { q: "shop" }, headers: @headers
      expect(response.parsed_body["projects"].first["name"]).to eq("House shopping")
      get "/api/v1/search", params: { q: "grocer" }, headers: @headers
      expect(response.parsed_body["tasks"].first["title"]).to eq("Buy groceries")
    end
  end
end
