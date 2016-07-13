require 'spec_helper'

describe 'Creating an ETD work' do
  context 'as the ETD manager' do
    let(:etd_manager_email) { 'etd_manager@example.com' }
    let(:etd_manager_account) { FactoryGirl.create(:account, email: etd_manager_email) }
    let(:etd_manager_user) { etd_manager_account.user }

    it 'defaults to open visibility' do
      login_as(etd_manager_user)
      visit new_curation_concern_etd_path
      expect(page).to have_checked_field('visibility_open')
    end

    it 'supports special fields for this work-type' do
      login_as(etd_manager_user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'ETD'

      within '#new_etd' do
        fill_in "etd_title", with: "Submitter profile link test"
        fill_in "etd_abstract", with: "test abstract"
        fill_in "etd_creator", with: "Test etd creator"

        # Special fields
        fill_in "etd_advisor", with: "Ross, Bob"
        fill_in "etd_committee_member", with: "Ross, Bill"
        find('#etd_college').find(:xpath, 'option[3]').select_option
          # option[2] = "Arts & Sciences"
        fill_in "etd_department", with: "Biology"
        fill_in "etd_degree", with: "MS"
        fill_in "etd_date_created", with: "2015"

        select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the distribution license agreement")
        click_button("Create ETD")
      end

      within ('.etd.attributes') do
        expect(page).to have_selector(:css, "li.advisor", text: "Ross, Bob")
        expect(page).to have_selector(:css, "li.committee_member", text: "Ross, Bill")
        expect(page).to have_selector(:css, "li.degree_for_display", text: "2015, MS, University of Cincinnati, Arts and Sciences : Biology")
      end
    end

    describe 'with a related link' do
      it "should allow me to attach the link on the create page" do
        login_as(etd_manager_user)
        visit root_path
        click_link "add-content"
        classify_what_you_are_uploading 'ETD'

        within '#new_etd' do
          fill_in "etd_title", with: "craft beer roof party YOLO fashion axe"
          fill_in "etd_abstract", with: "Test abstract"
          fill_in "etd_creator", with: "Test etd creator"

          fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
          select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
          check("I have read and accept the distribution license agreement")
          click_button("Create ETD")
        end
        expect(page).to have_selector('h1', text: 'ETD')

        within ('.linked_resource.attributes') do
          expect(page).to have_link('http://www.youtube.com/watch?v=oHg5SJYRHA0', href: 'http://www.youtube.com/watch?v=oHg5SJYRHA0')
        end

        # then I should find it in the search results.
        fill_in 'Search Curate', with: 'roof party'
        click_button 'keyword-search-submit'

        within('#documents') do
          expect(page).to have_link('craft beer roof party YOLO fashion axe') #title
          expect(page).to have_selector('dd', text: 'Test abstract')
          expect(page).to have_selector('dd', text: 'Test etd creator')
        end
      end
    end
  end

  context 'as a regular user' do
    let(:account) { FactoryGirl.create(:account) }
    let(:user) { account.user }

    it 'should not allow me to create new ETDs' do
      login_as(user)
      visit new_curation_concern_etd_path

      expect(page.status_code).to eq(404)
    end
  end
end

describe 'An existing ETD owned by me' do
  let(:user) { FactoryGirl.create(:user) }
  let(:etd) { FactoryGirl.create(:etd, user: user) }
  let(:you_tube_link) { 'http://www.youtube.com/watch?v=oHg5SJYRHA0' }

  it 'should allow me to attach a linked resource' do
    login_as(user)
    visit curation_concern_etd_path(etd)
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
    visit curation_concern_etd_path(etd)
    click_link 'Add an External Link'
    page.should have_link('Cancel', href: catalog_index_path)
  end
end

describe 'Viewing an ETD that is private' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:private_etd, title: "Sample work" ) }

  it 'should show a stub indicating we have the work, but it is private' do
    login_as(user)
    visit curation_concern_etd_path(work)
    page.should have_content('Unauthorized')
    page.should have_content('The ETD you have tried to access is private')
    page.should have_content("ID: #{work.pid}")
    page.should_not have_content("Sample work")
  end
end

