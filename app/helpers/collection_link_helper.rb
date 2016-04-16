module CollectionLinkHelper
	def create_link(collection)
		if collection.human_readable_type == "Profile"
			p = Person.find(depositor: collection.depositor).first
			link = "/people/#{p.representative}"
		else
			link = "/collections/#{collection.pid}"
		end
	end
end