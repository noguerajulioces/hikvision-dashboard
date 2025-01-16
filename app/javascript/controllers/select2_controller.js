import { Controller } from "@hotwired/stimulus"
import "select2";

export default class extends Controller {
  static targets = ["select"];

  connect() {
    this.initializeSelect2();
  }

  initializeSelect2() {
    this.selectTarget.classList.add("select2");
    $(this.selectTarget).select2({
      placeholder: "Selecciona una opción",
      allowClear: true,
    });
  }
}