require 'spec_helper'

describe 'College facet' do
  before(:all) { FactoryGirl.create(:public_generic_work, college: 'Business', department: 'Marketing') }

  it 'appears' do
    visit '/'

    expect(page).to have_css('div#collapse_College')
    expect(page).to have_css('a.facet_select', text: 'Business')
  end

  context 'when college selected' do
    it 'department facet appears' do
      visit '/'
      click_link 'Business'

      expect(page).to have_css('div#collapse_Program_or_Department')
      expect(page).to have_css('a.facet_select', text: 'Marketing')
    end
  end

  context 'when college not selected' do
    it 'department facet does not appear' do
      visit '/'

      expect(page).to_not have_css('div#collapse_Program_or_Department')
      expect(page).to_not have_css('a.facet_select', text: 'Marketing')
    end
  end
end
