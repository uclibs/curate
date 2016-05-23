require 'spec_helper'

describe 'curate/collections/show.html.erb' do
  let(:parent_collection) { FactoryGirl.build(:collection, title: "Top Level Collection") }
  let(:child_collection) { FactoryGirl.build(:collection, title: "Inner Level Collection") }

  it "displays the parent/child relationship between nested collections" do
    parent_collection.add_member(child_collection)
    assign(:collection, child_collection)
    render 'parent_collections_list', locals: {collection: child_collection}

    expect(rendered).to have_content('Parent Collections')
    expect(rendered).to have_content('Top Level Collection')
  end

  it "doesn't display parent_collections_list partial on top level collections" do
    parent_collection.add_member(child_collection)
    assign(:collection, parent_collection)
    render 'parent_collections_list', locals: {collection: parent_collection}

    expect(rendered).to_not have_content('Parent Collections')
  end
end
