require 'spec_helper'

describe 'curate/collections/_form_to_add_member.html.erb' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }

  let(:other_person) { FactoryGirl.create(:person_with_user) }
  let(:other_user) { other_person.user }

  let(:profile)         { double(title: 'Your Profile',      pid: 'sufia:abcde', noid: 'abcde') }
  let(:collectible)     { double(title: 'A Document',        pid: 'sufia:vwxyz', noid: 'vwxyz', edit_users: [user.email]) }
  let(:profile_section) { double(title: 'A Profile Section', pid: 'sufia:56789', noid: '56789') }

  before do
    view.stub(:current_users_profile_sections).and_return([profile_section])
    view.stub(:available_collections).and_return([])
    view.stub(:available_profiles).and_return([profile])
  end

  it 'should list profile and profile sections in the dropdown menu' do
    render partial: 'form_to_add_member', locals: { collectible: collectible, current_user: user }

    expect(rendered).to include(profile.title)
    expect(rendered).to include(profile_section.title)
  end

  it 'should NOT list profile when the collectible is un-editable' do
    render partial: 'form_to_add_member', locals: { collectible: collectible, current_user: other_user }

    expect(rendered).to_not include(profile.title)
    expect(rendered).to include(profile_section.title)
  end

end
