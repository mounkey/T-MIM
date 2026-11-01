# Preview all emails at http://localhost:3000/rails/mailers/capacity_mailer
class CapacityMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/capacity_mailer/capacity_warning_email
  def capacity_warning_email
    CapacityMailer.capacity_warning_email
  end
end
