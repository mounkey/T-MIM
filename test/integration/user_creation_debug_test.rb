require "test_helper"

class UserCreationDebugTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "simulates user creation and prints response" do
    # Create an admin user to login
    # Check if admin already exists to avoid unique constraint errors
    admin = User.find_by(email: "admin_debug@mim.cl")
    unless admin
      admin = User.create!(name: "Admin Debug", email: "admin_debug@mim.cl", password: "password", run: "11111111-1", role: :admin)
    end

    sign_in admin

    # Simulate POST request
    # IMPORTANT: We changed routes to 'gestion_usuarios' so users_path maps there.
    post users_path, params: {
      user: {
        name: "New User Unique",
        run: "33333333-3",
        email: "new_unique@mim.cl",
        password: "password",
        password_confirmation: "password",
        role: "user"
      }
    }, as: :turbo_stream

    puts "\n--- RESPONSE BODY START ---"
    puts response.body
    puts "--- RESPONSE BODY END ---\n"
  end
end
