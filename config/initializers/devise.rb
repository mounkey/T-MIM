# frozen_string_literal: true

Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  # Devise will use the `secret_key_base` as its `secret_key`
  # by default. You can change it below and use your own secret key.
  config.secret_key = ENV['DEVISE_SECRET_KEY'] if ENV['DEVISE_SECRET_KEY'].present?

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # Configure the class responsible to send e-mails.
  # config.mailer = 'Devise::Mailer'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters must be added to the Validatable module and to the columns
  # in the User model.
  # config.authentication_keys = [:email]

  # Configure parameters from the request object used for access request.
  # Default is [:http_auth] for valid parameters.
  # config.request_keys = []

  # Case insensitive keys.
  config.case_insensitive_keys = [:email]

  # Strip whitespace keys.
  config.strip_whitespace_keys = [:email]

  # Enable parameter sanitizer and permit custom parameters.
  # config.params_authenticatable = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 11. If
  # using other algorithms, it may be different. Given that it takes real time
  # to hash the password, you may want to reduce it in your test environment
  # and raise it in production.
  config.stretches = Rails.env.test? ? 1 : 12

  # Define logic for reconfirmable.
  config.reconfirmable = true

  # Define which will be the expire time of password reset.
  config.reset_password_within = 6.hours

  # Define the sign out method.
  config.sign_out_via = :delete

  # ==> Responder Configuration
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

end
