// app/javascript/controllers/dependent_select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "subCategory"]
  static values = { map: Object } // recibe el hash Service.map_for_js

  connect() {
    this.update()
  }

  update() {
    const category = this.categoryTarget.value
    const options = this.mapValue[category] || []

    const current = this.subCategoryTarget.value
    this.subCategoryTarget.innerHTML = ""

    const prompt = document.createElement("option")
    prompt.value = ""
    prompt.textContent = "Selecciona una subcategoría"
    this.subCategoryTarget.appendChild(prompt)

    options.forEach((name) => {
      const opt = document.createElement("option")
      opt.value = name
      opt.textContent = name
      if (name === current) opt.selected = true
      this.subCategoryTarget.appendChild(opt)
    })
  }
}
