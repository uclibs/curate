require 'spec_helper'

describe CurationConcern::Work do
  context '.ids_from_tokens' do
    it 'splits tokens on commas' do
      expect(described_class.ids_from_tokens("ab , cd ")).to eq(['ab', 'cd'])
    end
  end

  describe '#locally_managed_remote_identifier?' do
    let(:work) { FactoryGirl.build(:generic_work) }

    context 'when #identifier_url is set' do
      before { work.stub(:identifier_url).and_return("http://example.org") }
      it 'is true' do
        expect(work.locally_managed_remote_identifier?).to eq(true)
      end
    end

    context 'when #identifier_url is not set' do
      before { work.stub(:identifier_url).and_return(nil) }
      it 'is false' do
        expect(work.locally_managed_remote_identifier?).to eq(false)
      end
    end
  end

  describe '#doi_status' do
    let(:work) { FactoryGirl.build(:generic_work) }

    context 'when the work is public' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }
        it 'is "public"' do
          expect(work.doi_status).to eq("public")
        end
      end

      context 'and a DOI has not already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "public"' do
          expect(work.doi_status).to eq("public")
        end
      end
    end

    context 'when the work is embargoed' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }
        it 'is "unavailable"' do
          expect(work.doi_status).to eq("unavailable")
        end
      end

      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "reserved"' do
          expect(work.doi_status).to eq("reserved")
        end
      end
    end

    context 'when the work is authenticated' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }
        it 'is "unavailable"' do
          expect(work.doi_status).to eq("unavailable")
        end
      end

      context 'and a DOI has not already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "reserved"' do
          expect(work.doi_status).to eq("reserved")
        end
      end
    end

    context 'when the work is restricted' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }
        it 'is "unavailable"' do
          expect(work.doi_status).to eq("unavailable")
        end
      end

      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "reserved"' do
          expect(work.doi_status).to eq("reserved")
        end
      end
    end
  end

  describe "#attached_files_and_links" do
    let(:work) { FactoryGirl.create(:generic_work) }

    context 'links and files' do
      before { work.stub(:generic_files) { ['file', 'file'] } }
      before { work.stub(:linked_resources) { ['link'] } }

      it 'returns array with links and files' do
        expect(work.attached_files_and_links.class).to eq(Array)
        expect(work.attached_files_and_links.length).to eq(3)
      end
    end

    context 'links, no files' do
      before { work.stub(:linked_resources) { ['link'] } }

      it 'returns array with only links' do
        expect(work.attached_files_and_links.class).to eq(Array)
        expect(work.attached_files_and_links.length).to eq(1)
      end
    end
 
    context 'files, no links' do
      before { work.stub(:generic_files) { ['file', 'file'] } }

      it 'returns array with only files' do
        expect(work.attached_files_and_links.class).to eq(Array)
        expect(work.attached_files_and_links.length).to eq(2)
      end
    end

    context 'no links or files' do
      it 'returns nil' do
        puts work.generic_files
        expect(work.attached_files_and_links).to eq(nil)
      end
    end
  end

  describe '#synchronize_link_and_file_permissions' do
    let(:work) { FactoryGirl.create(:generic_work_with_files) }

    it 'adds and removes additional edit users to attached assets' do
      expect(work.generic_files.first.edit_users.length).to eq(1)
      work.edit_users += ["foo"]
      work.save
      work.reload

      work.synchronize_link_and_file_permissions
      expect(work.generic_files.first.edit_users.length).to eq(2)

      work.edit_users -= ["foo"]
      work.save
      work.reload

      work.synchronize_link_and_file_permissions
      expect(work.generic_files.first.edit_users.length).to eq(1)
    end

    it 'adds and removes additional edit groups to attached assets' do
      expect(work.generic_files.first.edit_groups.length).to eq(0)
      work.edit_groups += ["foo"]
      work.save
      work.reload

      work.synchronize_link_and_file_permissions
      expect(work.generic_files.first.edit_groups.length).to eq(1)

      work.edit_groups -= ["foo"]
      work.save
      work.reload

      work.synchronize_link_and_file_permissions
      expect(work.generic_files.first.edit_groups.length).to eq(0)
    end

    it 'does not copy visibility read groups' do
      work.read_groups = ['public']
      work.save
      work.reload

      work.generic_files.first.read_groups = []
      work.generic_files.first.save
      work.generic_files.first.reload      

      work.synchronize_link_and_file_permissions

      expect(work.read_groups).to eq(['public'])
      expect(work.generic_files.first.read_groups).to eq([])
    end
  end

  describe '#synchronize_link_and_file_ownership' do
    let(:work) { FactoryGirl.create(:generic_work_with_files) }
    let(:new_owner) { FactoryGirl.build(:user) }
    let(:new_owner_email) { new_owner.email }
    
    before do
      work.owner = new_owner_email
      work.save
      work.reload
      work.synchronize_link_and_file_ownership
    end

    it 'sets ownership for attached assets' do
      expect(work.generic_files.first.owner).to eq(new_owner_email)
      expect(work.generic_files.last.owner).to eq(new_owner_email)
    end
  end

  describe "#to_solr" do
    describe "sorting" do
      let(:work) { FactoryGirl.build(:generic_work) }

      describe "sort_title_ssi" do
        it "removes leading spaces" do
          work.stub(:title).and_return("  I start with a space")
          expect(work.to_solr["sort_title_ssi"]).to eq("I START WITH A SPACE")
        end

        it "removes leading articles" do
          work.stub(:title).and_return("The the is first")
          expect(work.to_solr["sort_title_ssi"]).to eq("THE IS FIRST")
        end

        it "removes non alphanumeric characters" do
          work.stub(:title).and_return("Title* 30! Sure& $has$ a &lot& of ^^^punctuation!!!!")
          expect(work.to_solr["sort_title_ssi"]).to eq("TITLE 30 SURE HAS A LOT OF PUNCTUATION")
        end

        it "removes double spaces" do
          work.stub(:title).and_return("This  title has      extra   spaces")
          expect(work.to_solr["sort_title_ssi"]).to eq("THIS TITLE HAS EXTRA SPACES")
        end

        it "upcases everything" do
          work.stub(:title).and_return("i should be uppercase")
          expect(work.to_solr["sort_title_ssi"]).to eq("I SHOULD BE UPPERCASE")
        end
        
        it "adds leading 0s as needed" do
          work.stub(:title).and_return("1) Is the first title")
          expect(work.to_solr["sort_title_ssi"]).to eq("00000000000000000001 IS THE FIRST TITLE")

          work.stub(:title).and_return("111) Is the eleventy-first title")
          expect(work.to_solr["sort_title_ssi"]).to eq("00000000000000000111 IS THE ELEVENTYFIRST TITLE")
        end
      end
    end
  end
end
