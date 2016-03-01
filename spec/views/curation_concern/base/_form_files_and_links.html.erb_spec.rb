require 'spec_helper'

describe 'curation_concern/base/_format_help_link.html.erb' do 

	before do
		render partial: 'format_help_link'
	end

	it 'should display file format help link' do
		expect(rendered).to have_link("Format File Advice help page")
	end
end