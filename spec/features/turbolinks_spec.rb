require 'spec_helper'

describe 'When viewing anything but the work create view turbolinks' do
	it 'is disabled on the application root' do
		visit root_path
		body.include?('<body data-no-turbolink="true">').should be_true
	end

	it 'is disabled on the catalog browse view' do
		visit('/catalog')
		body.include?('<body data-no-turbolink="true">').should be_true
	end
	
	let(:person) { FactoryGirl.create(:person_with_user) }
  	let(:user) { person.user }
	
	it 'is disabled on the work show view' do
		login_as(user)
		visit new_curation_concern_generic_work_path
		within '#new_generic_work' do
	    	fill_in "Title", with: "My title"
	    	select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
	    	check("I have read and accept the distribution license agreement")
	    	click_button("Create Generic Work")
		end
		body.include?('<body data-no-turbolink="true">').should be_true
	end
end

describe 'When viewing the work create view and the attach file view turbolinks' do
	let(:person) { FactoryGirl.create(:person_with_user) }
  	let(:user) { person.user }
	it 'is enabled on the work create view' do
		login_as(user)
		visit new_curation_concern_generic_work_path
    	body.include?('<body data-no-turbolink="false">').should be_true
	end
	generic_work = FactoryGirl.create(:generic_work)
	it 'is enabled on the attach a file view' do
		login_as(user)
		visit curation_concern_generic_work_path generic_work.pid
		body.include?('<body data-no-turbolink="true">').should be_true
	end
end
