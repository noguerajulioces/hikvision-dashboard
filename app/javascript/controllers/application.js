import { Application } from "@hotwired/stimulus"
import PasswordVisibility from "stimulus-password-visibility";
import { NestedForm } from "@stimulus-components/nested-form"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

application.register("password-visibility", PasswordVisibility)
application.register("nested-form", NestedForm)

export { application }
