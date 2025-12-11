import { Controller } from "@hotwired/stimulus"

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

  stop(event) {
    event.stopPropagation()
  }
}
