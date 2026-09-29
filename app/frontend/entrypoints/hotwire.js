// Hotwire entry: Turbo + Stimulus for the server-rendered pages (settings, login).
import "@/rails.css"
import "@hotwired/turbo-rails"
import { Application } from "stimulus"
import ConfirmController from "@/hotwire/controllers/confirm_controller"

window.Stimulus = Application.start()
Stimulus.register("confirm", ConfirmController)
