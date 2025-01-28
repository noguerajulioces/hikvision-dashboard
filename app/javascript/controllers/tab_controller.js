import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tab"
export default class extends Controller {
  static targets = ["tab", "content"]

  switch(event) {
    const selectedTab = event.currentTarget.dataset.tab
    
    // Update tab styles
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tab === selectedTab) {
        tab.classList.add("border-indigo-500", "text-indigo-600")
        tab.classList.remove("border-transparent", "text-gray-500")
      } else {
        tab.classList.remove("border-indigo-500", "text-indigo-600")
        tab.classList.add("border-transparent", "text-gray-500")
      }
    })

    // Show/hide content
    this.contentTargets.forEach(content => {
      if (content.dataset.tab === selectedTab) {
        content.classList.remove("hidden")
      } else {
        content.classList.add("hidden")
      }
    })
  }
}
