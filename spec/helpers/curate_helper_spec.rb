require 'spec_helper'

describe ApplicationHelper do

  context '#collection_title_from_pid' do
    let(:value) { 'abc' }
    let(:collection) { double(title: 'Title') }
    it 'should load the value and return the title' do
      Collection.should_receive(:load_instance_from_solr).with(value).and_return(collection)
      expect(helper.collection_title_from_pid(value)).to eq(collection.title)
    end
    it 'should attempt to load the value, fail, and return the value' do
      Collection.should_receive(:load_instance_from_solr).with(value).and_return(nil)
      expect(helper.collection_title_from_pid(value)).to eq(value)
    end
  end

  context '#creator_name_from_pid' do
    let(:value) { 'abc' }
    let(:collection) { double(name: 'Name') }
    it 'should load the value and return the name' do
      Person.should_receive(:load_instance_from_solr).with(value).and_return(collection)
      expect(helper.creator_name_from_pid(value)).to eq(collection.name)
    end
    it 'should attempt to load the value, fail, and return the value' do
      Person.should_receive(:load_instance_from_solr).with(value).and_return(nil)
      expect(helper.creator_name_from_pid(value)).to eq(value)
    end
  end

  it 'has #default_page_title' do
    expect(helper.default_page_title).to(
      eq("#{controller_name.titleize} // #{I18n.t('sufia.product_name')}")
    )
  end

  it 'has #curation_concern_page_title' do
    expect(helper.curation_concern_page_title(GenericWork.new)).to(
      eq("New Generic Work // #{I18n.t('sufia.product_name')}")
    )
  end

  describe '#curation_concern_meta_tags' do
    let(:meta_tags) do
      { 'Author' => %w(Lucy Xuemao),
        'Subject' => %w(Cheese) }
    end
    let(:html_meta_tags) do
      "<meta name='Author' content='Lucy'/>\n<meta name='Author' content='Xuemao'/>\n<meta name='Subject' content='Cheese'/>"
    end
    let(:work) { double('generic_work', meta_tags: meta_tags) }

    it 'renders the meta tags as meta tag html' do
      expect(helper.curation_concern_meta_tags(work)).to eq(html_meta_tags)
    end
  end

  describe '#curation_concern_attribute_to_html' do
    def render_curation_concern_attribute_html(expected_label, *item_or_collection)
      collection = Array(item_or_collection).flatten.compact
      have_tag('tr') do
        with_tag("th", text: expected_label)
        with_tag('td ul.tabular') do
          if collection.present?
            collection.each do |value|
              with_tag('li.attribute.things', text: value)
            end
          else
            yield if block_given?
          end
        end
      end
    end

    it 'handles an array by rendering one <dd> per element' do
      collection = ["<h2>", "Johnny Tables"]
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      rendered.should render_curation_concern_attribute_html('Weird', collection)
    end

    it 'handles a string by rendering one <dd>' do
      collection = "Tim"
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      rendered.should render_curation_concern_attribute_html('Weird', collection)
    end

    it 'returns a '' for a nil value' do
      collection = nil
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird")
      expect(rendered).to eq("")
    end

    it 'extracts name based on attribute registry' do
      collection = "Hello World"
      object = double('curation_concern', things: collection)
      object.should_receive(:label_for).with(:things).and_return("Bacon")

      rendered = helper.curation_concern_attribute_to_html(object, :things)
      rendered.should render_curation_concern_attribute_html('Bacon', collection)
    end

    it 'calculates the label based on method name' do
      collection = "Hello World"
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things)
      rendered.should render_curation_concern_attribute_html('Things', collection)
    end

    it 'returns a '' for an empty array' do
      collection = []
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things)
      expect(rendered).to eq("")
    end

    it 'returns a string for an empty array if allow_empty is passed' do
      collection = []
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things, "Weird", include_empty: true)
      rendered.should render_curation_concern_attribute_html('Weird') do
        without_tag('li.attribute.things')
      end
    end

    it 'converts sting line breaks to html breaks' do
      collection = "Foo\nBar"
      object = double('curation_concern', things: collection)

      rendered = helper.curation_concern_attribute_to_html(object, :things)
      rendered.should have_css('br')
    end
  end

  it 'has #classify_for_display' do
    expect(helper.classify_for_display(GenericWork.new)).to eq('generic work')
  end

  describe '#link_to_edit_permissions' do
    let(:solr_document) {
      {
        Hydra.config[:permissions][:read][:group] => access_policy,
        Hydra.config[:permissions][:embargo_release_date] => embargo_release_date
      }
    }
    let(:user) { FactoryGirl.create(:user) }
    let(:curation_concern) {
      FactoryGirl.create_curation_concern(
        :generic_work, user, visibility: visibility
      )
    }
    let(:visibility) { nil }
    let(:access_policy) { nil }
    let(:embargo_release_date) { nil }
    describe 'with a "registered" access group' do
      let(:expected_label) { t('sufia.institution_name') }
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED } # Can we change this?
      let(:access_policy) { 'registered' }
      it 'renders an Institution only label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-info", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
    describe 'with a "public" access group' do
      let(:access_policy) { 'public' }
      describe 'without embargo release date' do
        let(:expected_label) { "Open Access" }
        let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}
        it 'renders an "Open Access" label' do
          rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
          expect(rendered).to(
            have_tag("a#permission_#{curation_concern.to_param}") {
              with_tag("span.label.label-success", with: {title: expected_label }, text: expected_label)
            }
          )
        end
      end

      describe 'with an embargo release date' do
        let(:expected_label) { "Open Access with Embargo" }
        let(:embargo_release_date) { Date.today.to_s }
        let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}
        it 'renders an "Open Access with Embargo" label' do
          rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
          expect(rendered).to(
            have_tag("a#permission_#{curation_concern.to_param}") {
              with_tag("span.label.label-warning", with: {title: expected_label }, text: expected_label)
            }
          )
        end
      end
    end

    describe 'with a mixed "public registered" access group' do
      # This test is purely speculative to the appropriate labeling behavior and
      # does not account for whether the document is truly accessable; I suppose
      # I'm persisting hash drive development via a Solr document
      let(:expected_label) { "Open Access" }
      let(:access_policy) { 'public registered' }
      it 'renders an "Open Access" label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-success", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
    describe 'without an access group' do
      let(:expected_label) { "Private" }
      let(:access_policy) { nil }
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      it 'renders an "Private" label' do
        rendered = helper.link_to_edit_permissions(curation_concern, solr_document)
        expect(rendered).to(
          have_tag("a#permission_#{curation_concern.to_param}") {
            with_tag("span.label.label-important", with: {title: expected_label }, text: expected_label)
          }
        )
      end
    end
  end

  it "should have link for google.com" do
    helper.auto_link_without_protocols("google.com").should have_link("http://google.com")
  end

  describe '#sorted_college_list_for_degrees' do
  before do
      stub_const("COLLEGE_AND_DEPARTMENT",
                  {"current_colleges_for_degrees"=> 
                    {
                      "ceas"=>{"label"=>"Engineering"},
                      "com"=>{"label"=>"Arts & Sciences"},
                    },
                   "additional_current_colleges"=> 
                    {
                      "ucl"=>{"label"=>"Libraries"},
                      "ucba"=>{"label"=>"Blue Ash College"},
                    },
                  }
                )
    end


    it "should return an array" do
     expect(helper.sorted_college_list_for_degrees).to be_an(Array) 
    end

<<<<<<< HEAD
    it "should contain all the colleges for degrees, plus additional colleges, 'other'" do
=======
    it "should contain all the colleges for degrees, plus additional collectes, 'other'" do
>>>>>>> d6b1b063a927e0e603957282b5cc8855633555e6
      expect(helper.sorted_college_list_for_degrees).to eq(
       ['Arts & Sciences','Blue Ash College','Engineering','Libraries','Other']
      )
    end
  end

  describe '#sorted_college_list_for_generic_works' do
    before do
      stub_const("COLLEGE_AND_DEPARTMENT",
                  {"current_colleges_for_degrees"=> 
                    {
                      "ceas"=>{"label"=>"Engineering"},
                      "com"=>{"label"=>"Arts & Sciences"},
                    },
                   "additional_current_colleges"=> 
                    {
                      "ucl"=>{"label"=>"Libraries"},
                      "ucba"=>{"label"=>"Blue Ash College"},
                    },
                  }
                )
    end

    it "should return an array" do
      expect(helper.sorted_college_list_for_degrees).to be_an(Array) 
    end

    it "should contain all the colleges for degrees, plus additional colleges, plus 'other'" do
      expect(helper.sorted_college_list_for_generic_works).to eq(
       ['Arts & Sciences','Blue Ash College','Engineering','Libraries','Other']
      )
    end
  end

  describe '#sorted_college_list_for_etds' do
    before do
      stub_const("COLLEGE_AND_DEPARTMENT",
                  {"current_colleges_for_degrees"=> 
                    {
                      "ceas"=>{"label"=>"One"},
                      "com"=>{"label"=>"Two"},
                    },
                   "legacy_colleges"=> 
                   [
                     "Foo",
                     "Bar",
                     "Bez"
                   ]
                  }
                )
    end

    it "should add the legacy college list to the end of the sorted college list" do
      expect(helper.sorted_college_list_for_etds).to eq(
        ["One", "Two", "Other", "Foo", "Bar", "Bez"]
      )
    end

    it "should return an array" do
      expect(helper.sorted_college_list_for_etds).to be_an(Array) 
    end
  end

  describe '#work_types_for_student_works' do
    let(:types) { Curate.configuration.registered_curation_concern_types }
    it 'should return an array' do
      expect(helper.work_types_for_student_works).to be_an(Array)
    end

    it 'should contain all the work types except student work and Etd' do
      expect(helper.work_types_for_student_works.length).to eq(types.length - 2)
    end
  end
end
