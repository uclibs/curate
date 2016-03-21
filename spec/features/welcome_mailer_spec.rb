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
	end
	it 'should send welcome email to user' do
		email.to.should == [user_email]
		email.from.should == ["scholar@uc.edu"]
	end

end