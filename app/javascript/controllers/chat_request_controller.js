import { Controller } from "@hotwired/stimulus"

// Controla la apertura/cierre del formulario de contacto al proveedor
export default class extends Controller {
  static targets = ["form", "trigger", "textarea"]
  static values = {
    loggedIn: Boolean,
    loginPath: String,
  }

  toggle(event) {
    event.preventDefault()

    if (!this.loggedInValue) {
      window.location.href = this.loginPathValue
      return
    }

    if (this.formTarget.classList.contains("d-none")) {
      this.formTarget.classList.remove("d-none")
      this.triggerTarget.classList.add("d-none")
      this.textareaTarget?.focus()
    } else {
      this.formTarget.classList.add("d-none")
      this.triggerTarget.classList.remove("d-none")
    }
  }
}
