import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="number-format"
export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.formatNumber.bind(this))
  }

  formatNumber(e) {
    let value = e.target.value.replace(/\D/g, '').replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    e.target.value = value
  }
}
