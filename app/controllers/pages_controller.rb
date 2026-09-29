class PagesController < ApplicationController
  layout "spa"

  # SPA shell for every canvas route (/today, /projects/:id, …).
  def app
  end
end
