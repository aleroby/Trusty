import { Controller } from "@hotwired/stimulus"

// Envía el formulario al presionar Enter (Shift+Enter añade salto)
export default class extends Controller {
  static targets = ["input", "form"]

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.formTarget.requestSubmit()
    }
  }
}
