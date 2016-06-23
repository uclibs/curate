require 'spec_helper'

describe 'curation_concern/generic_works/_attributes.html.erb' do
  let(:person) { FactoryGirl.create(:person_with_user, name: "Shark Man!") }
  let(:user) { person.user }
  let(:curation_concern) { FactoryGirl.create(:generic_work, user: user) }

  let(:manager_account) { FactoryGirl.create(:account, email: 'manager@example.com', name: "Mr. Manager") }
  let(:manager_user) { manager_account.user }
  let(:manager_work) { FactoryGirl.create(:generic_work, user: manager_user) }

  context 'when viewing a work owned by a manager' do
    it 'the submitter attribute should be blank' do
      render 'attributes', curation_concern: manager_work, locals: { curation_concern: manager_work }
      expect(rendered).to_not have_selector('a', text: "#{manager_user.name}")
      expect(rendered).to have_content("Submitter")
    end
  end

  context 'when viewing a work owned by a regular user' do
    it 'the submitter attribute should link to the owners profile' do
      render 'attributes', curation_concern: curation_concern, locals: { curation_concern: curation_concern }
      expect(rendered).to have_selector('a', text: "#{user.name}")
    end
  end
end