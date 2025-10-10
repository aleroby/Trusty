import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]
  static values = { locale: { type: String, default: "es-AR" } }

  connect() {
    this.update() // se ejecuta en cada render de Turbo
  }

  update() {
    const v = Number(this.inputTarget.value || 0)
    this.outputTarget.textContent = this.format(v)
  }

  format(n) {
    // Si querés con símbolo y sin decimales:
    // return n.toLocaleString(this.localeValue, { style: "currency", currency: "ARS", minimumFractionDigits: 0 })
    return `$${n.toLocaleString(this.localeValue)}`
  }
}
