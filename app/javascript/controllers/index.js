// app/javascript/controllers/index.js
// Carga automáticamente todos los *_controller.js dentro de app/javascript/controllers
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)
