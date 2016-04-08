require 'spec_helper'

describe StudentWork do
  subject(:work) { FactoryGirl.build(:student_work) }

  it { should have_unique_field(:description) }
  it { should have_multivalue_field(:advisor) }
  it { should have_multivalue_field(:alternate_title) }
  it { should have_unique_field(:bibliographic_citation) }
  it { should have_multivalue_field(:contributor) }
  it { should have_multivalue_field(:coverage_spatial) }
  it { should have_multivalue_field(:coverage_temporal) }
  it { should have_multivalue_field(:creator) }
  it { should have_unique_field(:date_created) }
  it { should have_unique_field(:date_modified) }
  it { should have_unique_field(:date_uploaded) }
  it { should have_unique_field(:degree) }
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
  it { should have_unique_field(:type) }

  it { should respond_to(:unit) }

  it { should have_unique_field(:human_readable_type) }

  describe '#build_unit' do
    ## not using the subject here because we're calling #build_unit with a FactoryGirl callback
    let(:new_work) { StudentWork.new }
    before { new_work.build_unit }

    it 'should build a node with a blank college' do
      expect(new_work.unit.first).to respond_to(:college)
      expect(new_work.unit.first.college).to be_blank
    end

    it 'should build a node with a blank department' do
      expect(new_work.unit.first).to respond_to(:department)
      expect(new_work.unit.first.department).to be_blank
    end
  end

  describe '#college' do
    before { subject.stub(:unit).and_return([OpenStruct.new(college: ["foo"], department: ["bar"])]) }

    it 'returns the college' do
      expect(work.college).to eq("foo")
    end

    it 'returns nil if unit not build' do

    end
  end

  describe '#department' do
    before { subject.stub(:unit).and_return([OpenStruct.new(college: ["foo"], department: ["bar"])]) }

    it 'returns a department' do
      expect(work.department).to eq("bar")
    end
  end

  describe '#unit_for_display' do
    context 'with college and department set' do
      before do
        subject.stub(:college).and_return("Foo")
        subject.stub(:department).and_return("Bar")
      end

      it 'should return both' do
        expect(work.unit_for_display).to eq("Foo : Bar")
      end
    end

    context 'with college and department blank' do
      before do
        subject.stub(:college).and_return("")
        subject.stub(:department).and_return("")
      end

      it 'should return nil' do
        expect(work.unit_for_display).to eq(nil)
      end
    end

    context 'with just college set' do
      before do
        subject.stub(:college).and_return("Foo")
        subject.stub(:department).and_return("")
      end

      it 'should return college' do
        expect(work.unit_for_display).to eq("Foo")
      end
    end

    context 'with just department set' do
      before do
        subject.stub(:college).and_return("")
        subject.stub(:department).and_return("Bar")
      end

      it 'should return department' do
        expect(work.unit_for_display).to eq("Bar")
      end
    end
  end
end
