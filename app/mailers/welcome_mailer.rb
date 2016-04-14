class WelcomeMailer < ActionMailer::Base
	default from: 'scholar@uc.edu'
	def welcome_email(email)
		@email = email
		new_user = User.find_by_email(@email)
		if new_user.student?
			mail(
				to: @email,
				subject: 'Welcome to Scholar@UC, UC students!',
				template_name: 'welcome_email_student.html.erb',
				)
		else
			mail(
				to: @email,
				subject: 'Welcome to Scholar@UC!',
				template_name: 'welcome_email.html.erb',
				)
		end
	end
end
