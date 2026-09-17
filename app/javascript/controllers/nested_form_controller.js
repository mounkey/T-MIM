import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["target", "template"]
  static values = {
    placeholder: { type: String, default: "NEW_RECORD" }
  }

  add(event) {
    event.preventDefault()

    // Find the template. If the event target has a 'data-nested-form-template-value' use that,
    // otherwise fallback to the first 'template' target.
    let templateContent = null
    const templateId = event.currentTarget.dataset.templateId

    if (templateId) {
        const templateElement = document.getElementById(templateId)
        if (templateElement) {
            templateContent = templateElement.content
        }
    } else {
        templateContent = this.templateTarget.content
    }

    if (!templateContent) return;

    // Determine the placeholder to replace. Prefer the button's data attribute,
    // fallback to the controller's value.
    const placeholder = event.currentTarget.dataset.nestedFormPlaceholderValue || this.placeholderValue
    const regex = new RegExp(placeholder, 'g')

    // Replace the placeholder with a unique timestamp
    const wrapper = document.createElement('div')
    wrapper.innerHTML = templateContent.cloneNode(true).firstElementChild.outerHTML.replace(regex, new Date().getTime())

    // Insert before the target
    this.targetTarget.insertAdjacentElement('beforebegin', wrapper.firstElementChild)
  }

  remove(event) {
    event.preventDefault()

    const wrapper = event.target.closest('.nested-form-wrapper')

    // Check if it's a new record using the dataset we put on the wrapper
    // Note: The wrapper is the element with class 'nested-form-wrapper'
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'
      const input = wrapper.querySelector("input[name*='_destroy']")
      if (input) input.value = '1'
    }
  }
}
