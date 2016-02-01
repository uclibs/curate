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

  describe '#sortable_title' do
    let(:collection) { FactoryGirl.create(:collection, title: "A title") }

    it 'filters articles from the beginning of titles' do
      expect(collection.sortable_title).to eq("title")
    end
  end
end
