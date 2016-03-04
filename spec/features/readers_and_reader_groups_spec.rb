require 'spec_helper'

describe "Readers and Reader Groups" do
  let(:owner_person) { FactoryGirl.create(:person_with_user) }
  let(:owner) { owner_person.user }
  let(:reader_person) { FactoryGirl.create(:person_with_user) }
  let(:reader) { reader_person.user }
  let(:group) { FactoryGirl.create(:group) }
  let(:work) { FactoryGirl.create(:private_generic_work, user: owner) }

  before(:each) do
    FactoryGirl.create_generic_file(work, owner) do |gf|
      gf.visibility = work.visibility
      gf.title = "Test title"
    end
  end

  describe "adding/removing a reader" do
    it "gives/removes read access to the work" do
      work.add_reader(reader)
      work.save!
      work.synchronize_link_and_file_permissions
      login_as(reader)
      visit curation_concern_generic_work_path(work)

      # Can view work
      page.should have_content(work.title)

      # Can view files
      page.should have_content(work.generic_files.first.title.first)

      # Removing reader
      work.remove_reader(reader)
      work.save!
      work.synchronize_link_and_file_permissions


      # Can not view work
      visit curation_concern_generic_work_path(work)
      page.should_not have_content(work.title)

      # Can not view file
      visit curation_concern_generic_file_path(work.generic_files.first)
      page.should_not have_content(work.generic_files.first.title.first)
    end
  end


  describe "adding/removing a reader group" do
    it "gives/removes reader group members read access to the work" do
      group.add_member(reader_person)
      work.add_reader_group(group)
      work.save!
      work.synchronize_link_and_file_permissions
      login_as(reader)
      visit curation_concern_generic_work_path(work)

      # Can view work
      page.should have_content(work.title)

      # Can view files
      page.should have_content(work.generic_files.first.title.first)

      # Removing reader
      work.remove_reader_group(group)
      work.save!
      work.synchronize_link_and_file_permissions


      # Can not view work
      visit curation_concern_generic_work_path(work)
      page.should_not have_content(work.title)

      # Can not view file
      visit curation_concern_generic_file_path(work.generic_files.first)
      page.should_not have_content(work.generic_files.first.title.first)
    end
  end
end
