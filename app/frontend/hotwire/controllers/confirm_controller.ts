import { Controller } from "stimulus"

// data-controller="confirm" — asks before submitting a destructive form.
export default class extends Controller<HTMLFormElement> {
  submit(event: Event) {
    const message = this.element.dataset.confirmMessage ?? "Are you sure?"
    if (!window.confirm(message)) event.preventDefault()
  }
}
