// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import DependentSelectController from "./dependent_select_controller"

window.Stimulus = Application.start()
Stimulus.register("dependent-select", DependentSelectController)

