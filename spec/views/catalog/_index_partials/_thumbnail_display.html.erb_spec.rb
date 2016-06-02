require 'spec_helper'
describe 'catalog/_index_partials/_thumbnail_display' do
  context 'Person: ' do
    context 'Gravatar Image: ' do
      let(:person) { FactoryGirl.create(:person, representative: '1234') }
      before do
        person.stub(:representative_image_url).and_return('http://www.gravatar.com/avatar/998e373d9226f0ac08b7b52084f32ac6/?s=300')
        render partial: 'thumbnail_display', locals: { document: person }
      end
      it 'should display gravatar as thumbnail' do
        rendered.should include("http://www.gravatar.com/avatar/998e373d9226f0ac08b7b52084f32ac6/?s=300")
      end
    end

    context 'Uploaded Image: ' do
      let(:person) { FactoryGirl.create(:person, representative: '1234') }
      before do
        person.stub(:representative_image_url).and_return('/downloads/1234?datastream_id=thumbnail')
        render partial: 'thumbnail_display', locals: { document: person }
      end
      it 'should display uploaded image as thumbnail' do
        rendered.should include("/downloads/1234?datastream_id=thumbnail")
      end
    end
  end

  context 'Work: ' do
    let(:document) { FactoryGirl.create(:generic_work, representative: '1234') }
    before do
      render partial: 'thumbnail_display', locals: { document: document }
    end
    it 'should display selected representative as thumbnail' do
      rendered.should include("/downloads/1234?datastream_id=thumbnail")
    end

    it 'should link to the work' do
      rendered.should include("/works/generic_works/#{document.noid}")
    end
  end

  context 'People' do
    let(:person) { Factory.build(:person) }
    before do
      render partial: 'thumbnail_display', locals: { document: person }
    end

    it 'should link to the person' do
      rendered.should include("/people/#{person.noid}")
    end
  end

  context 'Collection' do
    let(:collection) { Factory.build(:collection) }
    before do
      render partial: 'thumbnail_display', locals: { document: collection }
    end

    it 'should link to the collection' do
      rendered.should include("/collections/#{collection.pid}")
    end
  end
end
