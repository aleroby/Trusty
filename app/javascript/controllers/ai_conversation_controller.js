import { Controller } from "@hotwired/stimulus"

// Maneja clicks en links dentro de la conversación para cargar el sidebar de detalles
export default class extends Controller {
  static values = { chatId: Number }

  open(event) {
    const link = event.target.closest("a")
    if (!link) return

    const href = link.getAttribute("href") || ""
    const url = this.safeURL(href)
    if (!url) return

    // Prioridad: links que ya apuntan a /chats/:id/details
    if (url.pathname.match(/\/chats\/\d+\/details/)) {
      event.preventDefault()
      this.visitInSidebar(url.pathname + url.search)
      return
    }

    // Si el link apunta a /services/:id -> redirige al details del chat con service_id
    const serviceMatch = url.pathname.match(/\/services\/(\d+)/)
    if (serviceMatch && this.hasChatIdValue) {
      event.preventDefault()
      const serviceId = serviceMatch[1]
      const detailsPath = `/chats/${this.chatIdValue}/details?service_id=${serviceId}`
      this.visitInSidebar(detailsPath)
    }
  }

  safeURL(href) {
    try {
      return new URL(href, window.location.origin)
    } catch (e) {
      return null
    }
  }

  visitInSidebar(path) {
    if (window.Turbo) {
      window.Turbo.visit(path, { frame: "ai_chats_sidebar_details" })
    }
  }
}
