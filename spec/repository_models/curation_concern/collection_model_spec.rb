require 'spec_helper'

describe CurationConcern::CollectionModel do
  let(:klass) {
    Class.new(ActiveFedora::Base) {
      include CurationConcern::CollectionModel
      def members; @members ||= []; end
      def save; true; end
    }
  }

  context '.add_member' do
    let(:collectible?) { nil }
    let(:proposed_collectible) { double(collections: []) }
    subject { klass.new }
    before(:each) {
      proposed_collectible.stub(:can_be_member_of_collection?).with(subject).and_return(collectible?)
      proposed_collectible.stub(:save).and_return(true)
    }

    context 'with itself' do
      it 'does not add it to the collection\'s members' do
        expect {
          subject.add_member(subject)
        }.to_not change{ subject.members.size }
      end
    end

    context 'with a non-collectible object' do
      let(:collectible?) { false }
      it 'does not add it to the collection\'s members' do
        expect {
          subject.add_member(proposed_collectible)
        }.to_not change{ subject.members.size }
      end
    end

    context 'with a collectible object' do
      let(:collectible?) { true }
      it 'adds it to the collection\'s members' do
        expect {
          subject.add_member(proposed_collectible)
        }.to change{ subject.members.size }.by(1)
      end
    end
  end

  describe '#members_from_solr' do
    let(:collection) { FactoryGirl.create(:collection, title: "A title") }
    let(:collection2) { FactoryGirl.create(:collection, title: "A subcollection") }
    let(:article) { FactoryGirl.create(:article, title: "test collection article") }

    before { collection.add_member(article) }

    it 'returns an instance of RSolr::Response::PaginatedDocSet' do
      expect(collection.members_from_solr.class).to eq(RSolr::Response::PaginatedDocSet)
    end

    it 'returns items in the collection' do
      expect(collection.members_from_solr.collect do |member|
        member["active_fedora_model_ssi"]
      end).to include("Article")
    end

    it 'returns subcollections' do
      collection.add_member(collection2)
      expect(collection.members_from_solr.collect do |member|
        member["active_fedora_model_ssi"]
      end).to include("Collection")
    end

    it 'returns the same member count as fedora' do
      expect(collection.members.length).to eq(collection.members_from_solr.length)
    end
  end

  describe '#to_solr' do  
    describe "indexing" do
      let(:collection) { FactoryGirl.create(:collection) }
      let(:reloaded_collection) { Collection.find(collection.pid) }

      let(:subcollection) { FactoryGirl.create(:collection) }
      let(:reloaded_subcollection) { Collection.find(subcollection.pid) }

      let(:user) { FactoryGirl.create(:person_with_user)  }
      let(:profile) { user.profile }
      let(:reloaded_profile){ Profile.find(profile.pid)  }

      it 'indexes collection when member of a collection' do
        collection.add_member(subcollection)
        reloaded_collection.members.should == [subcollection]
        reloaded_subcollection.to_solr["collection_sim"].should == [collection.pid]
      end

      it 'does not index profile whem member of a profile' do
        profile.add_member(subcollection)
        reloaded_profile.members.should == [subcollection]  
        reloaded_subcollection.to_solr["collection_sim"].should_not == [profile.pid]
      end
    end
  end
end
