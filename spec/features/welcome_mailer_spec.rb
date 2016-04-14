require 'spec_helper'

#placed in features to have access to capybara

describe WelcomeMailer do
	let(:user_email) { 'example@test.com' }
	let(:user_password) { 'really_good_password' }
	let(:email) { ActionMailer::Base.deliveries.last }
	before :each do
		visit new_user_registration_path

		fill_in 'user_email', with: user_email
		fill_in 'user_password', with: user_password
		fill_in 'user_password_confirmation', with: user_password

		click_button 'Sign up'
	end
	after :each do
		ActionMailer::Base.deliveries = []
		User.find_by_email(user_email).delete
	end
	it 'should send welcome email to user upon registration' do
		email.to.should == [user_email]
		email.from.should == ["scholar@uc.edu"]
	end
	describe 'Shibboleth Logins' do
		let(:student_user) { FactoryGirl.create(:user, ucstatus: 'Student')}
		let(:student_email) { WelcomeMailer.welcome_email(student_user.email)}
		let(:faculty_user) { FactoryGirl.create(:user, ucstatus: 'AnythingElse')}
		let(:faculty_email) { WelcomeMailer.welcome_email(faculty_user.email)}
		it 'should should send a different email to students' do
			student_email.subject.should == "Welcome to Scholar@UC, UC students!"
		end
		it 'should send the default email to non-student users' do
			faculty_email.subject.should == "Welcome to Scholar@UC!"
		end
	end
end