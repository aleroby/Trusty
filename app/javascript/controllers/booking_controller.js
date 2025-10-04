import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking"
export default class extends Controller {
  static values = {
    rate: Number,      // precio por hora => services.price
    fee: Number,       // fee fijo (puede ser 0)
    currency: String   // "USD" por defecto
  }

  static targets = [
    "hours", "start", "end",
    "subtotal", "fee", "total",
    "subtotalCents", "feeCents", "totalCents",
    "unitPrice"
  ]

  connect() {
    // listeners
    this.startTarget?.addEventListener("change", () => this.syncEndFromHours())
    this.endTarget?.addEventListener("change", () => this.syncHoursFromTimes())
    this.hoursTarget?.addEventListener("input", () => this.syncEndFromHours())

    // init
    this.syncHoursFromTimes()
    this.updateTotals()
  }

  // ---- helpers ----
  money(n) {
    return (isFinite(n) ? n : 0).toLocaleString(undefined, {
      style: "currency",
      currency: this.currencyValue || "ARS"
    })
  }

  toHours(hhmm) {
    const [h, m] = (hhmm || "00:00").split(":").map(Number)
    return h + (m / 60)
  }

  hhmmFrom(start, hours) {
    const [h, m] = (start || "09:00").split(":").map(Number)
    const totalMins = h * 60 + m + Math.round((hours || 0) * 60)
    const nh = Math.floor(totalMins / 60) % 24
    const nm = totalMins % 60
    return `${String(nh).padStart(2,"0")}:${String(nm).padStart(2,"0")}`
  }

  // ---- syncers ----
  syncHoursFromTimes() {
    if (!this.hasStartTarget || !this.hasEndTarget || !this.hasHoursTarget) return
    const h = this.toHours(this.endTarget.value) - this.toHours(this.startTarget.value)
    const rounded = Math.max(0, Math.round(h * 2) / 2) // múltiplos de 0.5
    this.hoursTarget.value = rounded || this.hoursTarget.value || 1
    this.updateTotals()
  }

  syncEndFromHours() {
    if (!this.hasStartTarget || !this.hasEndTarget || !this.hasHoursTarget) return
    const hours = parseFloat(this.hoursTarget.value || "0")
    this.endTarget.value = this.hhmmFrom(this.startTarget.value || "09:00", hours)
    this.updateTotals()
  }

  updateTotals() {
    const rate = Number(this.rateValue || 0)
    const hours = parseFloat(this.hasHoursTarget ? this.hoursTarget.value : "0") || 0

    const subtotal = Math.max(0, hours * rate)
    const fee = (Number(this.feeValue || 0) * subtotal) / 100
    const total = subtotal + fee

    if (this.hasSubtotalTarget) this.subtotalTarget.textContent = this.money(subtotal)
    if (this.hasFeeTarget) this.feeTarget.textContent = this.money(fee)
    if (this.hasTotalTarget) this.totalTarget.textContent = this.money(total)

    if (this.hasSubtotalCentsTarget) this.subtotalCentsTarget.value = Math.round(subtotal * 100)
    if (this.hasFeeCentsTarget) this.feeCentsTarget.value = Math.round(fee * 100)
    if (this.hasTotalCentsTarget) this.totalCentsTarget.value = Math.round(total * 100)

    if (this.hasUnitPriceTarget) this.unitPriceTarget.value = rate
  }
}
