import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "searchInput", "employeeList"];

  openModal(event) {
    console.log("openModal");
    this.groupId = event.currentTarget.dataset.groupId;
    this.modalTarget.classList.remove("hidden");
  }

  closeModal() {
    this.modalTarget.classList.add("hidden");
  }

  searchEmployees(event) {
    const query = event.target.value;
  
    fetch(`/employees/search?query=${query}`, {
      headers: { "Accept": "application/json" },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Error fetching employees");
        }
        return response.json();
      })
      .then((data) => {
        this.employeeListTarget.innerHTML = data
          .map((employee) => {
            return `
              <li class="flex justify-between items-center py-2">
                <div>
                  <p class="text-sm font-medium text-gray-900">${employee.first_name} ${employee.last_name}</p>
                  <p class="text-xs text-gray-500">${employee.role}</p>
                </div>
                <button
                  type="button"
                  class="rounded-md bg-indigo-600 px-3 py-1 text-sm text-white hover:bg-indigo-500"
                  data-action="click->modal#addEmployee"
                  data-employee-id="${employee.id}">
                  Asociar
                </button>
              </li>
            `;
          })
          .join("");
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }  

  addEmployee(event) {
    const employeeId = event.target.dataset.employeeId;
    fetch(`/groups/${this.groupId}/add_employee`, {
      method: "POST",
      headers: { 
        "Content-Type": "application/json", 
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content 
      },
      body: JSON.stringify({ employee_id: employeeId }),
    }).then((response) => {
      if (response.ok) {
        location.reload();
      }
    });
  }
}
