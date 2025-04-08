import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entryTime", "exitTime"]
  
  connect() {
    console.log("Schedule time controller connected")
  }
  
  updateExitTime() {
    const entryTimeValue = this.entryTimeTarget.value
    
    if (entryTimeValue) {
      // Parse the entry time
      const entryTime = new Date(entryTimeValue)
      
      // Add 8 hours to create the exit time
      const exitTime = new Date(entryTime)
      exitTime.setHours(exitTime.getHours() + 8)
      
      // Format the exit time for the datetime-local input
      // Format: YYYY-MM-DDThh:mm
      const formattedExitTime = this.formatDateTime(exitTime)
      
      // Set the exit time value
      this.exitTimeTarget.value = formattedExitTime
    }
  }
  
  toggleLunch(event) {
    const isChecked = event.target.checked
    const exitTimeValue = this.exitTimeTarget.value
    
    if (exitTimeValue) {
      // Parse the current exit time
      const exitTime = new Date(exitTimeValue)
      
      // Add or subtract 1 hour based on checkbox state
      if (isChecked) {
        exitTime.setHours(exitTime.getHours() + 1)
      } else {
        exitTime.setHours(exitTime.getHours() - 1)
      }
      
      // Format and set the new exit time
      this.exitTimeTarget.value = this.formatDateTime(exitTime)
    }
  }
  
  // Helper method to format a Date object to YYYY-MM-DDThh:mm
  formatDateTime(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    
    return `${year}-${month}-${day}T${hours}:${minutes}`
  }
}