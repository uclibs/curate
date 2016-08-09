require 'spec_helper'

describe 'Proxy Deposit' do
  let(:user) { FactoryGirl.create(:user, first_name: 'Iron', last_name: 'Man') }
  let(:proxy) { FactoryGirl.create(:user, first_name: 'Tony', last_name: 'Starks') }
  let(:etd_manager_proxy) { FactoryGirl.create(:user, first_name: 'Some', last_name: 'Rando', email: 'etd_manager@example.com') }
  let(:user_person) { FactoryGirl.create(:account, user: user)}
  let(:proxy_person) { FactoryGirl.create(:account, user: proxy)}
  let(:etd_manager_proxy_person) { FactoryGirl.create(:account, user: etd_manager_proxy)}

  before do
    user.can_receive_deposits_from << proxy
    user.can_receive_deposits_from << etd_manager_proxy
  end

  it 'defaults to blank for owner, with Myself and user name' do
    login_as(proxy)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Article'

    within '#new_article' do
      expect(page).to have_selector('#article_owner', text: "")
      expect(page).to have_selector('#article_owner', text: "Myself")
      expect(page).to have_selector('#article_owner', text: user.name)
      expect(page).to have_selector("input[id$=_creator]", text: "")
    end
  end

  it 'auto-selects user as contributor when user is selected as owner' do
    login_as(proxy)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Article'

    within '#new_article' do
      select user.name, :from => 'article_owner'
      fill_in "Title", with: "My article"
      fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
      choose('Visible to the world.')
      check("I have read and accept the distribution license agreement")
      click_button("Create Article")
      expect(page).to have_selector('#article_owner', text: user.name)
    end
  end

  it 'auto-selects proxy as contributor when Myself is selected as owner' do
    login_as(proxy)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Article'

    within '#new_article' do
      select 'Myself', :from => 'article_owner'
      fill_in "Title", with: "My article"
      fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
      choose('Visible to the world.')
      check("I have read and accept the distribution license agreement")
      click_button("Create Article")
    end

    page.should have_content(proxy.name)

  end

  it 'sets user\'s college and department when user is selected is selected as owner' do
    login_as(proxy)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Article'

    within '#new_article' do
      select user.name, from: 'article_owner'
      expect(page).to have_field('article[college]', with: user.college)
      expect(page).to have_field('article[department]', with: user.department)
    end
  end

  it 'sets proxy\'s college and department when proxy is selected is selected as owner' do
    login_as(proxy)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Article'

    within '#new_article' do
      select 'Myself', from: 'article_owner'
      expect(page).to have_field('article[college]', with: proxy.college)
      expect(page).to have_field('article[department]', with: proxy.department)
    end
  end

  it 'does not auto-populate college and department fields for an Student Work' do
    login_as(proxy)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Student Work'

    within '#new_student_work' do
      select 'Myself', from: 'student_work_owner'
      find_field('student_work[college]').value.should eq ''
      find_field('student_work[department]').value.should eq ''
    end
  end

  it 'does not auto-populate college and department fields for an ETD' do
    login_as(etd_manager_proxy)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'ETD'

    within '#new_etd' do
      select 'Myself', from: 'etd_owner'
      find_field('etd[college]').value.should eq ''
      find_field('etd[department]').value.should eq ''
    end
  end


end
