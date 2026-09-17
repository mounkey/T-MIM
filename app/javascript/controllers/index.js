// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import ModalCloseController from "controllers/modal_close_controller"

eagerLoadControllersFrom("controllers", application)
application.register("modal-close", ModalCloseController)
