import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "status"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.abortController = null
    this.lastSavedValue = this.fieldTarget.value
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.abortCurrentRequest()
  }

  save() {
    clearTimeout(this.timeout)
    this.setStatus("Saving...")
    this.timeout = setTimeout(() => this.performSave(), 400)
  }

  saveNow() {
    clearTimeout(this.timeout)
    this.performSave()
  }

  submit(event) {
    event.preventDefault()
    this.saveNow()
  }

  async performSave() {
    const name = this.fieldTarget.value

    if (name === this.lastSavedValue) {
      this.setStatus("Saved")
      return
    }

    this.abortCurrentRequest()
    this.abortController = new AbortController()
    this.setStatus("Saving...")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        credentials: "same-origin",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({ brand: { name } }),
        signal: this.abortController.signal
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.errors?.join(", ") || "Unable to save")
      }

      this.fieldTarget.value = data.name
      this.lastSavedValue = data.name
      this.setStatus("Saved")
    } catch (error) {
      if (error.name === "AbortError") return

      this.setStatus(error.message || "Error")
    }
  }

  abortCurrentRequest() {
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  setStatus(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }
}
