require 'spec_helper'

describe Etd do
  subject(:work) { FactoryGirl.build(:etd) }

  it { should have_unique_field(:abstract) }
  it { should have_unique_field(:advisor) }
  it { should have_multivalue_field(:alternate_title) }
  it { should have_unique_field(:bibliographic_citation) }
  it { should have_multivalue_field(:contributor) }
  it { should have_multivalue_field(:coverage_spatial) }
  it { should have_multivalue_field(:coverage_temporal) }
  it { should have_unique_field(:college) }
  it { should have_multivalue_field(:creator) }
  it { should have_multivalue_field(:committee_member) }
  it { should have_unique_field(:date_created) }
  it { should have_unique_field(:date_modified) }
  it { should have_unique_field(:date_uploaded) }
  it { should have_unique_field(:degree) }
  it { should have_unique_field(:department) }
  it { should have_unique_field(:genre) }
  it { should have_unique_field(:identifier) }
  it { should have_multivalue_field(:language) }
  it { should have_unique_field(:note) }
  it { should have_unique_field(:publisher) }
  it { should have_unique_field(:publisher_digital) }
  it { should have_unique_field(:requires) }
  it { should have_unique_field(:rights) }
  it { should have_multivalue_field(:subject) }
  it { should have_unique_field(:title) }

  it { should have_unique_field(:human_readable_type) }

  describe '#unit_for_display' do
    context 'with college and department set' do
      before do
        subject.stub(:college).and_return("Foo")
        subject.stub(:department).and_return("Bar")
      end

      it 'should return both' do
        expect(subject.unit_for_display).to eq("Foo : Bar")
      end
    end

    context 'with college and department blank' do
      before do
        subject.stub(:college).and_return("")
        subject.stub(:department).and_return("")
      end

      it 'should return nil' do
        expect(subject.unit_for_display).to eq(nil)
      end
    end

    context 'with just college set' do
      before do
        subject.stub(:college).and_return("Foo")
        subject.stub(:department).and_return("")
      end

      it 'should return college' do
        expect(subject.unit_for_display).to eq("Foo")
      end
    end

    context 'with just department set' do
      before do
        subject.stub(:college).and_return("")
        subject.stub(:department).and_return("Bar")
      end

      it 'should return department' do
        expect(subject.unit_for_display).to eq("Bar")
      end
    end
  end
  describe '#degree_for_display' do
    context 'with college and department set' do
      before do
        subject.stub(:date_created).and_return("2016")
        subject.stub(:degree).and_return("MS")
        subject.stub(:college).and_return("Business")
        subject.stub(:department).and_return("Marketing")
        subject.stub(:publisher).and_return("UC")
      end

      it 'should return both' do
        expect(subject.degree_for_display).to eq("2016, MS, UC, Business : Marketing")
      end
    end

    context 'with all blank' do
      before do
        subject.stub(:date_created).and_return("")
        subject.stub(:degree).and_return("")
        subject.stub(:college).and_return("")
        subject.stub(:department).and_return("")
        subject.stub(:publisher).and_return("")
      end

      it 'should return nil' do
        expect(subject.degree_for_display).to eq(nil)
      end
    end

    context 'with just college blank' do
      before do
        subject.stub(:date_created).and_return("2016")
        subject.stub(:degree).and_return("MS")
        subject.stub(:college).and_return("")
        subject.stub(:department).and_return("Marketing")
        subject.stub(:publisher).and_return("UC")
      end

      it 'should return the field' do
        expect(subject.degree_for_display).to eq("2016, MS, UC, Marketing")
      end
    end

    context 'with just department blank' do
      before do
        subject.stub(:date_created).and_return("2016")
        subject.stub(:degree).and_return("MS")
        subject.stub(:college).and_return("Business")
        subject.stub(:department).and_return("")
        subject.stub(:publisher).and_return("UC")
      end

      it 'should return the field' do
        expect(subject.degree_for_display).to eq("2016, MS, UC, Business")
      end
    end

    context 'with just date_created blank' do
      before do
        subject.stub(:date_created).and_return("")
        subject.stub(:degree).and_return("MS")
        subject.stub(:college).and_return("Business")
        subject.stub(:department).and_return("Marketing")
        subject.stub(:publisher).and_return("UC")
      end

      it 'should return the field' do
        expect(subject.degree_for_display).to eq("MS, UC, Business : Marketing")
      end
    end

    context 'with just degree blank' do
      before do
        subject.stub(:date_created).and_return("2016")
        subject.stub(:degree).and_return("")
        subject.stub(:college).and_return("Business")
        subject.stub(:department).and_return("Marketing")
        subject.stub(:publisher).and_return("UC")
      end

      it 'should return the field' do
        expect(subject.degree_for_display).to eq("2016, UC, Business : Marketing")
      end
    end

    context 'with just publisher blank' do
      before do
        subject.stub(:date_created).and_return("2016")
        subject.stub(:degree).and_return("MS")
        subject.stub(:college).and_return("Business")
        subject.stub(:department).and_return("Marketing")
        subject.stub(:publisher).and_return("")
      end

      it 'should return the field' do
        expect(subject.degree_for_display).to eq("2016, MS, Business : Marketing")
      end
    end
  end
end
