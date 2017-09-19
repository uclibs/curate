class CollectionsReport < Report

  private

  def self.report_objects
    Collection.all
  end

  def self.fields(collection = Collection.new)
    [
      { pid: collection.pid },
      { title: collection.title },
      { creator: creator_name(collection) },
      { description: (collection.description.blank? ? "No Description" : collection.description) },
      { rights: "All rights reserved" },
      { visibility: collection.visibility },
      { thumbnail_url: collection.representative_image_url },
      { member_of_collections: collection.collection_ids.join("|") },
      { depositor: collection.depositor },
      { edit_users: collection.edit_users.join("|") },
      { works: collection.member_ids.join("|") }
    ]
  end

  def self.creator_name(collection)
    user = User.find_by_email collection.depositor
    user.nil? ? "" : user.inverted_name
  end
end
