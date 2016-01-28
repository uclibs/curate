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
  end
end
