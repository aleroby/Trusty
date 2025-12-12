import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.scroll()
    this.observer = new MutationObserver(() => this.scroll())
    this.observer.observe(this.containerTarget, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  scroll() {
    const el = this.containerTarget
    el.scrollTop = el.scrollHeight
  }
}
