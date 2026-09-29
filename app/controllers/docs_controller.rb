class DocsController < ApplicationController
  layout "docs"

  skip_before_action :authenticate_user!

  # GET /api/docs — Scalar reference UI (loads /api/openapi.yaml)
  def index
  end

  # GET /api/openapi.yaml — the generated spec (run `npm run docs:api` to rebuild)
  def openapi
    spec = Rails.root.join("doc/openapi.yaml")
    if spec.exist?
      send_file spec, type: "text/yaml", disposition: :inline
    else
      render plain: "Run `npm run docs:api` to generate doc/openapi.yaml", status: :not_found
    end
  end
end
