import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="review-stars"
export default class extends Controller {
  static targets = ["star", "ratingInput"]

  connect() {
    this.updateStars()
  }

  select(event) {
    const value = event.currentTarget.dataset.value
    this.ratingInputTarget.value = value
    this.updateStars(value)
  }

  updateStars(value = this.ratingInputTarget.value) {
    this.starTargets.forEach(star => {
      star.classList.toggle("bi-star-fill", star.dataset.value <= value)
      star.classList.toggle("bi-star", star.dataset.value > value)
    })
  }
}

