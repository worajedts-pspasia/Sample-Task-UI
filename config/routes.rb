Rails.application.routes.draw do
  # Health
  get "up" => "rails/health#show", as: :rails_health_check

  # API documentation (open — the demo has no secrets)
  get "/api/docs", to: "docs#index"
  get "/api/openapi.yaml", to: "docs#openapi"

  # Session (Hotwire)
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # API v1
  namespace :api do
    namespace :v1 do
      get "/bootstrap", to: "bootstrap#show"
      get "/csrf", to: "csrf#show"
      patch "/profile", to: "profile#update"
      get "/search", to: "search#show"
      delete "/trash/empty", to: "trash#empty"

      resources :tasks, only: [:index, :create, :show, :update, :destroy] do
        member do
          %i[complete uncomplete cancel schedule deadline remind move reorder restore].each do |action|
            post action
          end
        end
        collection { post :complete_all }
        resources :checklist_items, only: [:create, :update, :destroy]
      end

      resources :projects, only: [:index, :create, :show, :update, :destroy] do
        resources :headings, only: [:create, :update, :destroy]
      end
      resources :areas, only: [:index, :create, :show, :update, :destroy]
      resources :tags, only: [:index, :create, :update, :destroy]
    end
  end

  # Hotwire pages (settings) — must precede the SPA catch-all
  namespace :settings, path: "settings" do
    get "/", to: "accounts#show", as: :root
    get "/preferences", to: "preferences#edit"
    patch "/preferences", to: "preferences#update"
  end
  get "/projects/:id/edit", to: "settings/projects#edit"
  patch "/projects/:id", to: "settings/projects#update", as: :settings_project
  delete "/projects/:id/destroy", to: "settings/projects#destroy", as: :settings_project_destroy
  get "/areas/:id/edit", to: "settings/areas#edit"
  patch "/areas/:id", to: "settings/areas#update", as: :settings_area
  delete "/areas/:id/destroy", to: "settings/areas#destroy", as: :settings_area_destroy
  get "/tags", to: "settings/tags#index"
  post "/tags", to: "settings/tags#create", as: :settings_tags
  patch "/tags/:id", to: "settings/tags#update", as: :settings_tag
  delete "/tags/:id", to: "settings/tags#destroy", as: :settings_tag_destroy

  # SPA catch-all (canvas routes)
  root "pages#app"
  get "/*path" => "pages#app", format: false
end
