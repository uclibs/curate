require 'spec_helper'

describe BlacklightHelper do
  describe "#facet_display_value" do
    it "should just be the facet value for an ordinary facet" do
      helper.stub(:facet_configuration_for_field).with('simple_field').and_return(double(:query => nil, :date => nil, :helper_method => nil, :field => nil))
      helper.facet_display_value('simple_field', 'asdf').should == 'asdf'
    end

    it "should allow you to pass in a :helper_method argument to the configuration" do
      helper.stub(:facet_configuration_for_field).with('helper_field').and_return(double(:query => nil, :date => nil, :helper_method => :my_facet_value_renderer))

      helper.should_receive(:my_facet_value_renderer).with('qwerty').and_return('abc')

      helper.facet_display_value('helper_field', 'qwerty').should == 'abc'
    end

    it "should extract the configuration label for a query facet" do
      helper.stub(:facet_configuration_for_field).with('query_facet').and_return(double(:query => { 'query_key' => { :label => 'XYZ'}}, :date => nil, :helper_method => nil))
      helper.facet_display_value('query_facet', 'query_key').should == 'XYZ'
    end

    it "should localize the label for date-type facets" do
      helper.stub(:facet_configuration_for_field).with('date_facet').and_return(double('date' => true, :query => nil, :helper_method => nil))
      helper.facet_display_value('date_facet', '2012-01-01').should == 'Sun, 01 Jan 2012 00:00:00 +0000'
    end

    it "should localize the label for date-type facets with the supplied localization options" do
      helper.stub(:facet_configuration_for_field).with('date_facet').and_return(double('date' => { :format => :short }, :query => nil, :helper_method => nil))
      helper.facet_display_value('date_facet', '2012-01-01').should == '01 Jan 00:00'
    end

    it "should look-up a collection title when the field is 'collection_sim'" do
      helper.stub(:facet_configuration_for_field).with('collection_sim').and_return(double(:query => nil, :date => nil, :helper_method => nil, :field => 'collection_sim'))
      Collection.stub(:find).with('foo:123').and_return(double(title: 'Test Title'))
      helper.facet_display_value('collection_sim', 'foo:123').should == 'Test Title'
    end
  end

  describe '#render_filter_element' do
    before do
      controller.request.path_parameters["controller"] = 'catalog'

      @config = Blacklight::Configuration.new do |config|
        config.add_facet_field 'type'
      end
      helper.stub(:blacklight_config => @config)
    end

    it "should render the facet field and value" do
      result = helper.render_filter_element('type', ['journal'], {:q=>'biz'})

      result.size.should == 1
      # I'm not certain how the ampersand gets in there. It's not important.
      result.first.should have_content "Type:"
      result.first.should have_content "journal"
    end

    it "should render the facet field and value for collections" do
      Collection.stub(:find).with('foo:123').and_return(double(title: 'Test Title'))
      result = helper.render_filter_element('collection_sim', ['foo:123'], {:q=>'biz'})

      result.size.should == 1
      result.first.should have_content "Collection:"
      result.first.should have_content "Test Title"
    end
  end
end
