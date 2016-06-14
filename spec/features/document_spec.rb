require 'spec_helper'

describe 'Creating a document' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }

  it 'defaults to open visibility' do
    login_as(user)
    visit new_curation_concern_document_path
    expect(page).to have_checked_field('visibility_open')
  end

  describe 'with a related link' do
    it "should allow me to attach the link on the create page" do
      login_as(user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'Document'
      within '#new_document' do
        fill_in "Title", with: "Banksy fingerstache Polaroid artisan gastropub"
        fill_in "Creator", with: "Test document creator"
        fill_in "Description", with: "This document is for testing purposes"
        fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
        select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the distribution license agreement")
        click_button("Create Document")
      end
      expect(page).to have_selector('h1', text: 'Document')
      within ('.linked_resource.attributes') do
        expect(page).to have_link('http://www.youtube.com/watch?v=oHg5SJYRHA0', href: 'http://www.youtube.com/watch?v=oHg5SJYRHA0')
      end

      # then I should find it in the search results.
      fill_in 'Search Curate', with: 'fingerstache gastropub'
      click_button 'keyword-search-submit'
      within('#documents') do
        expect(page).to have_link('Banksy fingerstache Polaroid artisan gastropub') #title
        expect(page).to have_selector('dd', text: 'This document is for testing purposes')
        expect(page).to have_selector('dd', text: 'Test document creator')
      end
    end
  end
end

describe 'Viewing a Document that is private' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:private_document, title: "Sample work" ) }

  it 'should show a stub indicating we have the work, but it is private' do
    login_as(user)
    visit curation_concern_document_path(work)
    page.should have_content('Unauthorized')
    page.should have_content('The Document you have tried to access is private')
    page.should have_content("ID: #{work.pid}")
    page.should_not have_content("Sample work")
  end
end

