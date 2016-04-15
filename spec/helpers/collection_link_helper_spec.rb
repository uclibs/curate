require 'spec_helper'

describe CollectionLinkHelper do
  describe '#create_link' do
    let(:profile) { double(human_readable_type: "Profile", depositor: "foo") }
    let(:collection) { double(human_readable_type: "Collection", pid: "foo1234" ) }
    let(:user) { double(representative: "bar1234") }

    before do
      Person.stub(:find).and_return([user])
    end

	it 'links to a persons page for profiles' do	
      expect(helper.create_link(profile)).to eq("/people/#{user.representative}")
	end

	it 'links to a collection page for collections' do
      expect(helper.create_link(collection)).to eq("/collections/#{collection.pid}")
	end
  end
end