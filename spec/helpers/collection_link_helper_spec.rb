require 'spec_helper'

describe CollectionLinkHelper do
	describe '#create_link' do
		it 'links to a persons page' do	
			user = FactoryGirl.create(:person_with_user)
			profile = user.profile

			link = helper.create_link(profile)
			link.should == "/people/#{user.representative}"
		end

		it 'links to a collection page' do
			user = FactoryGirl.create(:person_with_user)
			my_collection = FactoryGirl.create(:public_collection, user: user, title: 'Collected Stuff') 

			link = helper.create_link(my_collection)
			link.should == "/collections/#{my_collection.pid}"
		end
	end
end