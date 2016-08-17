require 'spec_helper'

describe 'the collection icon' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }
  let(:other_person) { FactoryGirl.create(:person_with_user) }
  let(:other_user) { other_person.user }
  let!(:generic_work) { FactoryGirl.create(:generic_work, user: user) }
 
  after do
    logout
  end
 
  context 'in the catalog' do
    context 'with a logged in user' do
      it 'should be displayed if the work is owned by that user' do
        login_as(user)
        visit root_path
        body.should include(generic_work.noid + '-modal')
      end
 
      it 'should not be displayed if the work is not owned by that user' do
        login_as(other_user)
        visit root_path
        body.should_not include(generic_work.noid + '-modal')
      end
    end
  end

  context 'in the work show view' do
    context 'with a logged in user' do
      it 'should be displayed if the work is owned by that user' do
        login_as(user)
        visit curation_concern_generic_work_path generic_work.noid
        body.should include(generic_work.noid + '-modal')
      end

      it 'should not be displayed if the work is not owned by that user' do
        login_as(other_user)
        visit curation_concern_generic_work_path generic_work.noid
        body.should_not include(generic_work.noid + '-modal')
      end
    end
  end
end
