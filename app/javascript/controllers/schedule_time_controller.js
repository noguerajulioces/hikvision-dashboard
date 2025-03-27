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
      const year = exitTime.getFullYear()
      const month = String(exitTime.getMonth() + 1).padStart(2, '0')
      const day = String(exitTime.getDate()).padStart(2, '0')
      const hours = String(exitTime.getHours()).padStart(2, '0')
      const minutes = String(exitTime.getMinutes()).padStart(2, '0')
      
      const formattedExitTime = `${year}-${month}-${day}T${hours}:${minutes}`
      
      // Set the exit time value
      this.exitTimeTarget.value = formattedExitTime
    }
  }
}