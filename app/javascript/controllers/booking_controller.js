import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking"
export default class extends Controller {
  static values = {
    rate: Number,      // precio por hora => services.price
    fee: Number,       // fee fijo (puede ser 0)
    currency: String,   // "USD" por defecto
    durationMinutes: Number  // agregado para campo cantidad
  }

  static targets = [
    "quantity", "start", "end",
    "subtotal", "fee", "total",
    "subtotalCents", "feeCents", "totalCents",
    "unitPrice"
  ]

  connect() {
    this.startTarget?.addEventListener("change", () => this.syncEndTime())
    this.quantityTarget?.addEventListener("input", () => {
      this.syncEndTime()
      this.updateTotals()
    })
    this.syncEndTime()
    this.updateTotals()
  }

  syncEndTime() {
    if (!this.hasStartTarget || !this.hasEndTarget) return
    const startValue = this.startTarget.value
    if (!startValue) {
      this.endTarget.value = ""
      return
    }
    const qty = this.currentQuantity()
    const minutes = (this.durationMinutesValue || 0) * qty
    this.endTarget.value = this.hhmmFrom(startValue, minutes)
  }

  currentQuantity() {
    const qty = parseInt(this.quantityTarget?.value, 10)
    return Number.isFinite(qty) && qty > 0 ? qty : 1
  }

  hhmmFrom(start, minutes) {
    const [h, m] = (start || "00:00").split(":").map(Number)
    const totalMins = h * 60 + m + Number(minutes || 0)
    const nh = Math.floor(totalMins / 60) % 24
    const nm = totalMins % 60
    return `${String(nh).padStart(2, "0")}:${String(nm).padStart(2, "0")}`
  }

  // ---- helpers ----
  money(n) {
    return (isFinite(n) ? n : 0).toLocaleString(undefined, {
      style: "currency",
      currency: this.currencyValue || "ARS"
    })
  }


  updateTotals() {
    const rate = Number(this.rateValue || 0)
    const quantity = this.currentQuantity()
    const subtotal = quantity * rate
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
