require 'spec_helper'

describe 'Profile for a Person: ' do

  context 'logged in user' do
    let(:password) { FactoryGirl.attributes_for(:user).fetch(:password) }
    let(:account) { FactoryGirl.create(:account, first_name: 'Iron', last_name: "Man") }
    let(:user) { account.user }
    let(:person) { account.person }
    before { login_as(user) }

    # TODO: confirm the intent of this test
    it 'will see a link to their profile in the nav' do
      visit catalog_index_path
      page.should have_link("My Profile", href: user_profile_path)
    end

    it 'should see their name in the edit view' do
      visit catalog_index_path
      click_link 'My Profile'
      click_link 'Update Personal Information'
      expect(page).to have_field('First name', with: 'Iron')
      expect(page).to have_field('Last name', with: 'Man')
    end

    it 'should update their name and see the updated value' do
      visit catalog_index_path
      click_link 'My Profile'
      click_link 'Update Personal Information'
      page.should have_link("Cancel", href: person_path(person))
      within('form.edit_user') do
        fill_in("user[first_name]", with: 'Spider')
        fill_in("user[last_name]", with: 'Man')
        fill_in("user[current_password]", with: password)
        click_button "Update Account"
      end

      visit catalog_index_path
      click_link 'My Profile'
      page.should have_content('Spider Man')
    end

    it 'should be returned to the My Profile page after editing their profile' do
      visit catalog_index_path
      click_link 'My Profile'
      click_link 'Update Personal Information'
      within('form.edit_user') do
        fill_in("user[current_password]", with: password)
        click_button "Update Account"
      end
      page.should have_content('Update Personal Information')
    end
  end

  context "searching" do
    let(:manager_user) { FactoryGirl.create(:account, email: 'manager@example.com', name: 'Walter Langsam') }
    let!(:user) {manager_user.user}
    let!(:person) {manager_user.person}

    let!(:account) { FactoryGirl.create(:account, first_name: 'Bruce', last_name: 'Banner') }
    let!(:user_b) { account.user }
    let!(:person_b) { account.person }

    let!(:account_c) { FactoryGirl.create(:account, first_name: 'Carl', last_name: 'Weathers') }
    let!(:user_c) { account_c.user }
    let!(:person_c) { account_c.person }

    before { login_as(user_b) }

    it 'without edit access is not displayed in the results' do
      visit catalog_index_path
      fill_in 'Search Curate', with: 'Carl'
      click_button 'keyword-search-submit'
      within('#documents') do
        expect(page).to_not have_link('Carl Weathers') #title
      end
    end
    it 'with edit access is displayed in the results' do
      create_work
      logout
      visit catalog_index_path
      fill_in 'Search Curate', with: 'Bruce'
      click_button 'keyword-search-submit'
      within('#documents') do
        expect(page).to have_link('Bruce Banner') #title
      end
    end
    it 'should not show repository managers in search results' do
      visit catalog_index_path
      fill_in 'Search Curate', with: 'Walter'
      click_button 'keyword-search-submit'
      within('#documents') do
        expect(page).to_not have_link('Walter Langsam')
      end
    end
  end

  context "As a repository manager searching people" do
    let(:creating_user) { FactoryGirl.create(:user) }
    let(:email) { 'manager2@example.com' }
    let(:manager_user) { FactoryGirl.create(:user, email: email) }

    let(:manager_2) {FactoryGirl.create(:account, email: 'manager@example.com', first_name: 'Stan', last_name: 'Theman')}
    let!(:user) {manager_2.user}
    let!(:person) {manager_2.person}

    before do
      login_as(manager_user)
    end
    it "should see all users, including other managers" do
      visit catalog_index_path
      fill_in 'Search Curate', with: 'Stan'
      click_button 'keyword-search-submit'
      within('#documents') do
        expect(page).to have_link('Stan Theman') #title
      end
    end
  end

  context 'A person when logged in' do
    let(:password) { FactoryGirl.attributes_for(:user).fetch(:password) }
    let(:account) { FactoryGirl.create(:account, first_name: 'Iron', last_name: 'Man') }
    let(:user) { account.user }
    let(:person) { account.person }
    let(:image_file){ Rails.root.join('../fixtures/files/image.png') }
    before do
      login_as(user)
    end

    it 'should have a profile image in show view' do
      create_image(image_file)
      visit('/')
      click_link "My Profile"
      page.should have_css("img[src$='/downloads/#{person.pid}?datastream_id=medium']")
    end

    it 'should show gravatar image if profile image not uploaded' do
      visit('/')
      click_link "My Profile"
      page.should have_css("img[contains(gravatar)]")
    end
  end

  def create_image(image_file)
    visit("/")
    click_link "My Profile"
    click_link "Update Personal Information"
    within('form.edit_user') do
      attach_file("Upload a file", image_file)
      fill_in("user[current_password]", with: password)
      click_button "Update Account"
    end
  end

  protected

  def create_work
    visit("/")
    click_link "add-content"
    classify_what_you_are_uploading 'Generic Work'
    within '#new_generic_work' do
      fill_in "* Title", with: "test work"
      select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
      check("I have read and accept the distribution license agreement")
      click_button("Create Generic work")
    end
  end

end
