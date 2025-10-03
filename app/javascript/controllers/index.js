// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import DependentSelectController from "./dependent_select_controller"
import FiltersController from "./filters_controller";
import PriceRangeController from "./price_range_controller";
import BookingController from "./booking_controller";

window.Stimulus = Application.start()
Stimulus.register("dependent-select", DependentSelectController)
Stimulus.register("filters", FiltersController);
Stimulus.register("price-range", PriceRangeController); // opcional
