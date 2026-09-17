Rails.application.reloader.to_prepare do
  Devise::SessionsController.layout "devise"
  Devise::PasswordsController.layout "devise"
  Devise::UnlocksController.layout "devise"
  Devise::ConfirmationsController.layout "devise"
end
