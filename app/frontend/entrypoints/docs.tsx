import { StrictMode } from "react"
import { createRoot } from "react-dom/client"
import { ApiReferenceReact } from "@scalar/api-reference-react"
import "@/rails.css"

createRoot(document.getElementById("docs-root")!).render(
  <StrictMode>
    <ApiReferenceReact
      configuration={{
        spec: { url: "/api/openapi.yaml" },
        darkMode: false,
        hideClientButton: true,
      }}
    />
  </StrictMode>,
)
