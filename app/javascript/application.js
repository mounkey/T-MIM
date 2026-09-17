// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import * as bootstrap from "bootstrap"
import "@fortawesome/fontawesome-free"

// Expose Bootstrap globally for inline onclick handlers
window.bootstrap = bootstrap

// Initialize Bootstrap Tooltips
document.addEventListener("turbo:load", function() {
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })

  // Sidebar Toggle Logic
  const toggleBtn = document.getElementById("sidebarToggle");
  const sidebar = document.querySelector(".sidebar");
  const overlay = document.getElementById("sidebarOverlay");

  if (toggleBtn && sidebar) {
    toggleBtn.addEventListener("click", function() {
      sidebar.classList.toggle("show");
      if(overlay) overlay.classList.toggle("d-none");
    });
  }

  if (overlay) {
    overlay.addEventListener("click", function() {
      sidebar.classList.remove("show");
      overlay.classList.add("d-none");
    });
  }
});
