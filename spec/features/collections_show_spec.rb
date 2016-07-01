require 'spec_helper'

describe "Collections show view: " do

  let!(:user) { FactoryGirl.create(:user) }
  let!(:bilbo) { 'Bilbo' }
  let!(:frodo) { 'Frodo' }
  let!(:article) { FactoryGirl.create(:public_generic_work, user: user, creator: [bilbo, frodo], title: 'An Article') }
  let!(:collection) { FactoryGirl.create(:public_collection, user: user, title: 'Collected Stuff', members: [article]) }

  before do
    allow_any_instance_of(Curate::CollectionsHelper).to receive(:link_owner).and_return("<a href='#'>LINK</a>")
  end

  context "For logged in members:" do
    it "remove an item from the collection" do
      login_as(user)
      visit collection_path(collection.pid)
      page.should have_css(".collection-member[data-noid='#{article.noid}']")
      click_on "remove-#{article.noid}"

      visit collection_path(collection.pid)
      page.should_not have_css(".collection-member[data-noid='#{article.noid}']")
    end

    it "should display the delete button" do
      collection.save!
      login_as(user)
      visit collection_path(collection.pid)
      expect(page).to have_button('Delete')
    end
  end

  context "In public view: " do
    it "should not display remove_member link" do
      Capybara.reset_sessions!
      visit destroy_user_session_url
      visit collection_path(collection.pid)
      page.should_not have_css("a[title$='Remove Item from Collection']")
    end

    it "should display the collection owner" do
      visit collection_path(collection.pid)
      page.should have_content("Collection submitted by: LINK")
    end
  end

  context "Creators:" do
    it "should be displayed in each line items" do
      visit collection_path(collection.pid)
      page.should have_content('Frodo')
      page.should have_content('Bilbo')
    end
  end

  let(:collection_pid_html) { collection.pid.sub(/:/, '%3A') }
  let(:search_within_collection_link) { "/catalog?f%5Bcollection_sim%5D%5B%5D=#{collection_pid_html}" }
  it "shows a link to search within the collection" do
    visit collection_path(collection.pid)
    page.body.should have_link("Search within this collection", href: search_within_collection_link)
  end
end
