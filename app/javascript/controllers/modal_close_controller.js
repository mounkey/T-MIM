import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const modalElement = document.getElementById('mainModal')

    if (modalElement) {
      // Try to get the existing Bootstrap modal instance
      let modalInstance = window.bootstrap.Modal.getInstance(modalElement)

      if (modalInstance) {
        // Use the official API to hide it
        modalInstance.hide()
      } else {
        // Fallback: If no instance exists but the modal is visible (e.g. class 'show'),
        // create a new instance just to call hide() properly.
        // This handles cases where Turbo might have re-rendered parts of the page
        // losing the JS instance but keeping HTML state.
        if (modalElement.classList.contains('show')) {
             new window.bootstrap.Modal(modalElement).hide()
        }
      }

      // Additional Cleanup Safety:
      // Sometimes the backdrop remains if the animation is interrupted.
      // We wait a tiny bit for the Bootstrap animation to likely finish/start, then check.
      setTimeout(() => {
          const backdrops = document.querySelectorAll('.modal-backdrop');
          if (backdrops.length > 0 && !document.body.classList.contains('modal-open')) {
             backdrops.forEach(b => b.remove());
          }
      }, 500);
    }

    // Remove this controller element (the trigger div) from the DOM
    this.element.remove()
  }
}
