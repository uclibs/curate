require 'spec_helper'

describe 'Creating a student work' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }

  it 'defaults to open visibility' do
    login_as(user)
    visit new_curation_concern_student_work_path
    expect(page).to have_checked_field('visibility_open')
  end

  it 'supports special fields for this work-type' do
    login_as(user)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Student Work'

    within '#new_student_work' do
      fill_in "Title", with: "Submitter profile link test"
      fill_in "Description", with: "test description"
      fill_in "student_work_creator", with: "Test student work creator"

      # Special fields
      find('#student_work_type').find(:xpath, 'option[1]').select_option
        # option[2] = "Article"
      fill_in "Advisor", with: "Ross, Bob"
      find('#student_work_college').find(:xpath, 'option[3]').select_option
        # option[2] = "Arts & Sciences"
      fill_in "Program or Department", with: "Biology"
      fill_in "Degree", with: "BS"

      select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
      check("I have read and accept the distribution license agreement")
      click_button("Create Student Work")
    end

    within ('.student_work.attributes') do
      expect(page).to have_selector(:css, "li.type", text: "Article")
      expect(page).to have_selector(:css, "li.advisor", text: "Ross, Bob")
      expect(page).to have_selector(:css, "li.unit_for_display", text: "Arts and Sciences : Biology")
      expect(page).to have_selector(:css, "li.degree", text: "BS")
    end
  end

  it 'links to the submitters profile' do
    login_as(user)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Student Work'

    within '#new_student_work' do
      fill_in "Title", with: "Submitter profile link test"
      fill_in "Description", with: "test description"
      fill_in "student_work_creator", with: "Test student work creator"
      select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
      check("I have read and accept the distribution license agreement")
      click_button("Create Student Work")
    end

    #the submitter field should have a link to the submitter's profile
    within ('.student_work.attributes') do
      click_link "#{user.name}"
    end
    expect(page).to have_selector('h1', text: "#{user.name}")
  end
 
  describe 'with a related link' do
    it "should allow me to attach the link on the create page" do
      login_as(user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'Student Work'

      within '#new_student_work' do
        fill_in "Title", with: "craft beer roof party YOLO fashion axe"
        fill_in "Description", with: "My description"
        fill_in "student_work_creator", with: "Test student work creator"
        fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
        select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the distribution license agreement")
        click_button("Create Student Work")
      end
      expect(page).to have_selector('h1', text: 'Student Work')

      within ('.linked_resource.attributes') do
        expect(page).to have_link('http://www.youtube.com/watch?v=oHg5SJYRHA0', href: 'http://www.youtube.com/watch?v=oHg5SJYRHA0')
      end

      # then I should find it in the search results.
      fill_in 'Search Curate', with: 'roof party'
      click_button 'keyword-search-submit'

      within('#documents') do
        expect(page).to have_link('craft beer roof party YOLO fashion axe') #title
        expect(page).to have_selector('dd', text: 'My description')
        expect(page).to have_selector('dd', text: 'Test student work creator')
      end

    end
  end
end

describe 'An existing student work owned by me' do
  let(:user) { FactoryGirl.create(:user) }
  let(:student_work) { FactoryGirl.create(:student_work, user: user) }
  let(:you_tube_link) { 'http://www.youtube.com/watch?v=oHg5SJYRHA0' }

  it 'should allow me to attach a linked resource' do
    login_as(user)
    visit curation_concern_student_work_path(student_work)
    click_link 'Add an External Link'

    within '#new_linked_resource' do
      fill_in 'External link', with: you_tube_link
      click_button 'Add External Link'
    end

    within ('.linked_resource.attributes') do
      expect(page).to have_link(you_tube_link, href: you_tube_link)
    end
  end

  it 'cancel takes me back to the dashboard' do
    login_as(user)
    visit curation_concern_student_work_path(student_work)
    click_link 'Add an External Link'
    page.should have_link('Cancel', href: catalog_index_path)
  end
end

describe 'Viewing a student work that is private' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:private_student_work, title: "Sample work" ) }

  it 'should show a stub indicating we have the work, but it is private' do
    login_as(user)
    visit curation_concern_student_work_path(work)
    page.should have_content('Unauthorized')
    page.should have_content('The Student Work you have tried to access is private')
    page.should have_content("ID: #{work.pid}")
    page.should_not have_content("Sample work")
  end
end

