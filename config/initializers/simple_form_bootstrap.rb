# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Default configuration
  config.wrappers :default, class: :input,
    hint_class: :field_with_hint, error_class: :field_with_errors, valid_class: :field_without_errors do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label_input
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }
  end

  # Bootstrap 5 wrapper
  config.wrappers :vertical_form, tag: 'div', class: 'mb-3', error_class: 'is-invalid', valid_class: 'is-valid' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
    b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
    b.use :hint, wrap_with: { tag: 'div', class: 'form-text' }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :vertical_form

  # Define the way to render check boxes / radio buttons with labels.
  config.boolean_style = :nested

  # Default class for buttons
  config.button_class = 'btn'

  # Error notification class.
  config.error_notification_class = 'alert alert-danger'

  # Label class
  config.label_class = 'form-label'

  # Browser validations on by default
  config.browser_validations = true

  # File handling
  config.boolean_label_class = 'form-check-label'
end
