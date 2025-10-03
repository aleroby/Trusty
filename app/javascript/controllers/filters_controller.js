import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["categorySelect", "subcategorySelect"];
  static values = {
    map: Object,                 // { "Hogar": ["Limpieza", ...], ... }
    selectedSubcategory: String  // para preservar selección al cargar
  };

  connect() {
    this.populateSubcategories(); // inicial
  }

  onCategoryChange() {
    this.populateSubcategories();
  }

  populateSubcategories() {
    const cat = this.categorySelectTarget?.value || "";
    const selected = this.selectedSubcategoryValue || this.subcategorySelectTarget?.value || "";

    // Subcategorías por categoría, o bien todas si no hay categoría elegida
    const subcats = cat ? (this.mapValue[cat] || []) : this.allSubcats();

    // Limpiar y reconstruir options
    this.subcategorySelectTarget.innerHTML = "";
    this.subcategorySelectTarget.append(this.option("All", ""));

    subcats.forEach(sc => {
      const opt = this.option(sc, sc);
      if (sc === selected) opt.selected = true;
      this.subcategorySelectTarget.append(opt);
    });
  }

  allSubcats() {
    // aplanar y de-duplicar
    const flat = Object.values(this.mapValue || {}).flat();
    return [...new Set(flat)];
    // si querés mantener el orden de cada grupo, esto alcanza.
  }

  option(text, value) {
    const o = document.createElement("option");
    o.textContent = text;
    o.value = value;
    return o;
  }
}
