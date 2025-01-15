import { Application } from "@hotwired/stimulus"
import PasswordVisibility from "stimulus-password-visibility";

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

application.register("password-visibility", PasswordVisibility)
export { application }
