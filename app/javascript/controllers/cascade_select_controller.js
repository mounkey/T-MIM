import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    paramName: String,
    targetFrame: String
  }

  update(event) {
    const value = event.target.value
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set(this.paramNameValue, value)

    const frame = document.getElementById(this.targetFrameValue)
    if (frame) {
      frame.src = url.toString()
    }
  }
}
