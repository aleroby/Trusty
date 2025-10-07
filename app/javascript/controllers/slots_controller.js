// app/javascript/controllers/slots_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    serviceId: Number,
    durationMinutes: Number,
    stepMinutes: { type: Number, default: 30 }
  }

  static targets = ["select", "notice", "startInput", "endInput", "hours"]

  connect() {
    // Setear horas según la duración del servicio (refleja tu pricing)
    if (this.hasHoursTarget && this.durationMinutesValue) {
      const hrs = (this.durationMinutesValue / 60).toFixed(2).replace(/\.00$/, "")
      this.hoursTarget.value = hrs
      this._dispatchInput(this.hoursTarget) // para que booking recalcule
    }
  }

  async fetch(event) {
    const date = event?.target?.value
    if (!date) return

    this._resetUILoading()
    try {
      const url = `/services/${this.serviceIdValue}/available_slots?date=${encodeURIComponent(date)}`
      const res = await fetch(url, { headers: { "Accept": "application/json" } })
      const data = await res.json()

      this._fillSlots(data.slots || [])
      this._setNotice(data.slots && data.slots.length > 0
        ? `Duración del servicio: ${this.durationMinutesValue} min.`
        : "Sin turnos disponibles para este día.")
    } catch (e) {
      this._fillSlots([])
      this._setNotice("No se pudieron cargar los horarios. Intenta nuevamente.")
      // opcional: console.error(e)
    } finally {
      this.selectTarget.disabled = false
    }
  }

  selectSlot(event) {
    const hhmm = event.target.value
    if (!hhmm) {
      // limpiamos campos si no hay selección
      this._setTimeInput(this.startInputTarget, "")
      this._setTimeInput(this.endInputTarget, "")
      return
    }

    // Completar start_time
    this._setTimeInput(this.startInputTarget, hhmm)

    // Calcular y completar end_time según durationMinutes
    const endHHMM = this._addMinutesToHHMM(hhmm, this.durationMinutesValue)
    this._setTimeInput(this.endInputTarget, endHHMM)

    // Asegurar que "hours" refleje la duración del servicio
    if (this.hasHoursTarget) {
      const hrs = (this.durationMinutesValue / 60).toFixed(2).replace(/\.00$/, "")
      this.hoursTarget.value = hrs
      this._dispatchInput(this.hoursTarget)
    }

    // Disparar recalculo del controller "booking"
    this._dispatchInput(this.startInputTarget)
    this._dispatchInput(this.endInputTarget)
  }

  // ----------------- helpers -----------------
  _fillSlots(slots) {
    // slots: ["09:00","09:30", ...]
    const sel = this.selectTarget
    sel.innerHTML = `<option value="">Elegí un horario</option>`
    slots.forEach(hhmm => {
      const opt = document.createElement("option")
      opt.value = hhmm
      opt.textContent = hhmm
      sel.appendChild(opt)
    })
  }

  _resetUILoading() {
    this.selectTarget.disabled = true
    this.selectTarget.innerHTML = `<option>Cargando...</option>`
    this._setNotice("")
    // limpiar campos de tiempo
    if (this.hasStartInputTarget) this._setTimeInput(this.startInputTarget, "")
    if (this.hasEndInputTarget) this._setTimeInput(this.endInputTarget, "")
  }

  _setNotice(text) {
    if (this.hasNoticeTarget) this.noticeTarget.textContent = text
  }

  _setTimeInput(input, hhmm) {
    input.value = hhmm // "HH:MM" es aceptado por <input type="time">
  }

  _addMinutesToHHMM(hhmm, minutes) {
    const [h, m] = hhmm.split(":").map(Number)
    const date = new Date(2000, 0, 1, h, m, 0, 0)
    date.setMinutes(date.getMinutes() + Number(minutes || 0))
    const hh = String(date.getHours()).padStart(2, "0")
    const mm = String(date.getMinutes()).padStart(2, "0")
    return `${hh}:${mm}`
  }

  _dispatchInput(el) {
    el.dispatchEvent(new Event("input", { bubbles: true }))
    el.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
