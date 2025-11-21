import { Controller } from "@hotwired/stimulus"

// Maneja la selección de un chat y carga ambos frames (mensajes + detalles)
export default class extends Controller {
  static targets = ["conversationFrame", "detailsFrame"]

  open(event) {
    event.preventDefault()

    const conversationUrl = event.currentTarget.dataset.conversationUrl
    const detailsUrl = event.currentTarget.dataset.detailsUrl

    if (conversationUrl && this.hasConversationFrameTarget) {
      this.conversationFrameTarget.src = conversationUrl
    }

    if (detailsUrl && this.hasDetailsFrameTarget) {
      this.detailsFrameTarget.src = detailsUrl
    }
  }
}
