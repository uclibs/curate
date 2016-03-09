class WelcomeMailer < ActionMailer::Base

  def welcome_email(email)
    @email = email
    mail(from: 'scholar@uc.edu', to: @email, subject: 'Welcome to Scholar@UC!')
  end
end