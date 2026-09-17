import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step1", "step2", "step3",
    "buttonStep1", "buttonStep2", "submitButton", // Targets for navigation buttons
    "progressBar", "stepTitle",
    "categorySelect",
    "componentSelect", "componentInput", "componentSelectWrapper", "componentInputWrapper",
    "subComponentSelect", "subComponentInput", "subComponentSelectWrapper", "subComponentInputWrapper",
    "componentIdField", "subComponentIdField"
  ]

  connect() {
    this.currentStep = 1
    this.updateView()
  }

  updateView() {
    // Update Progress Bar
    const percent = ((this.currentStep - 1) / 2) * 100
    this.progressBarTarget.style.width = `${percent}%`

    // Update Steps Visibility (Content)
    this.step1Target.classList.toggle("d-none", this.currentStep !== 1)
    this.step2Target.classList.toggle("d-none", this.currentStep !== 2)
    this.step3Target.classList.toggle("d-none", this.currentStep !== 3)

    // Update Buttons Visibility
    // Step 1: Show Button1, Hide others
    if (this.hasButtonStep1Target) this.buttonStep1Target.classList.toggle("d-none", this.currentStep !== 1)
    // Step 2: Show Button2, Hide others
    if (this.hasButtonStep2Target) this.buttonStep2Target.classList.toggle("d-none", this.currentStep !== 2)
    // Step 3: Show Submit, Hide Next buttons
    if (this.hasSubmitButtonTarget) this.submitButtonTarget.classList.toggle("d-none", this.currentStep !== 3)


    // Update Title
    const titles = ["Seleccionar Categoría", "Definir Estructura", "Crear Regla"]
    this.stepTitleTarget.textContent = `${this.currentStep}. ${titles[this.currentStep - 1]}`
  }

  next() {
    // Limit Max Step to 3
    if (this.currentStep >= 3) return

    if (this.validateStep(this.currentStep)) {
      this.currentStep++
      this.updateView()
    }
  }

  previous() {
    if (this.currentStep > 1) {
      this.currentStep--
      this.updateView()
    }
  }

  validateStep(step) {
    if (step === 1) {
      if (!this.categorySelectTarget.value) {
        alert("Por favor, seleccione una categoría de activo.")
        return false
      }
      this.loadComponents(this.categorySelectTarget.value)
    }
    if (step === 2) {
       // Validate Component
       const compNew = !this.componentInputWrapperTarget.classList.contains("d-none")
       if (compNew && !this.componentInputTarget.value) { alert("Ingrese nombre del sistema"); return false }
       if (!compNew && !this.componentSelectTarget.value) { alert("Seleccione un sistema"); return false }

       // Validate SubComponent
       const subCompNew = !this.subComponentInputWrapperTarget.classList.contains("d-none")
       if (subCompNew && !this.subComponentInputTarget.value) { alert("Ingrese nombre del componente"); return false }
       if (!subCompNew && !this.subComponentSelectTarget.value) { alert("Seleccione un componente"); return false }
    }
    return true
  }

  // --- API Logic ---

  async loadComponents(categoryId) {
    // Reset fields
    this.resetComponentFields()

    try {
      const response = await fetch(`/planes_mantenimiento/components?asset_category_id=${categoryId}`)
      const data = await response.json()

      this.componentSelectTarget.innerHTML = "<option value=''>-- Seleccionar Sistema --</option>"
      data.forEach(item => {
        const option = document.createElement("option")
        option.value = item.id
        option.textContent = item.name
        this.componentSelectTarget.appendChild(option)
      })

      const newOption = document.createElement("option")
      newOption.value = "NEW"
      newOption.textContent = "+ Crear Nuevo Sistema..."
      newOption.style.fontWeight = "bold"
      this.componentSelectTarget.appendChild(newOption)

    } catch (e) {
      console.error("Error loading components", e)
    }
  }

  async loadSubComponents(componentId) {
    this.resetSubComponentFields()

    try {
      const response = await fetch(`/planes_mantenimiento/sub_components?component_id=${componentId}`)
      const data = await response.json()

      this.subComponentSelectTarget.innerHTML = "<option value=''>-- Seleccionar Componente --</option>"
      data.forEach(item => {
        const option = document.createElement("option")
        option.value = item.id
        option.textContent = item.name
        this.subComponentSelectTarget.appendChild(option)
      })

      const newOption = document.createElement("option")
      newOption.value = "NEW"
      newOption.textContent = "+ Crear Nuevo Componente..."
      newOption.style.fontWeight = "bold"
      this.subComponentSelectTarget.appendChild(newOption)

    } catch (e) {
      console.error("Error loading sub-components", e)
    }
  }

  // --- Event Handlers ---

  onComponentChange() {
    const val = this.componentSelectTarget.value
    if (val === "NEW") {
      this.componentSelectWrapperTarget.classList.add("d-none")
      this.componentInputWrapperTarget.classList.remove("d-none")
      this.componentIdFieldTarget.value = "" // Clear ID

      // If Component is new, SubComponent MUST be new
      this.forceNewSubComponent()
    } else {
      this.componentIdFieldTarget.value = val
      this.loadSubComponents(val)
    }
  }

  cancelNewComponent() {
    this.componentInputWrapperTarget.classList.add("d-none")
    this.componentSelectWrapperTarget.classList.remove("d-none")
    this.componentSelectTarget.value = ""
    this.componentInputTarget.value = ""

    // Reset SubComponent
    this.resetSubComponentFields()
  }

  onSubComponentChange() {
    const val = this.subComponentSelectTarget.value
    if (val === "NEW") {
      this.subComponentSelectWrapperTarget.classList.add("d-none")
      this.subComponentInputWrapperTarget.classList.remove("d-none")
      this.subComponentIdFieldTarget.value = ""
    } else {
      this.subComponentIdFieldTarget.value = val
    }
  }

  cancelNewSubComponent() {
    // Allow cancel only if parent is not NEW
    if (this.componentSelectTarget.value === "NEW") return

    this.subComponentInputWrapperTarget.classList.add("d-none")
    this.subComponentSelectWrapperTarget.classList.remove("d-none")
    this.subComponentSelectTarget.value = ""
    this.subComponentInputTarget.value = ""
  }

  // --- Helpers ---

  forceNewSubComponent() {
    this.subComponentSelectWrapperTarget.classList.add("d-none")
    this.subComponentInputWrapperTarget.classList.remove("d-none")
    this.subComponentSelectTarget.innerHTML = "" // Clear options
    this.subComponentIdFieldTarget.value = ""
  }

  resetComponentFields() {
    this.componentSelectWrapperTarget.classList.remove("d-none")
    this.componentInputWrapperTarget.classList.add("d-none")
    this.componentSelectTarget.innerHTML = "<option>Cargando...</option>"
    this.componentInputTarget.value = ""
    this.componentIdFieldTarget.value = ""

    this.resetSubComponentFields()
  }

  resetSubComponentFields() {
    this.subComponentSelectWrapperTarget.classList.remove("d-none")
    this.subComponentInputWrapperTarget.classList.add("d-none")
    this.subComponentSelectTarget.innerHTML = "<option>-- Seleccionar Sistema Primero --</option>"
    this.subComponentInputTarget.value = ""
    this.subComponentIdFieldTarget.value = ""
  }
}
