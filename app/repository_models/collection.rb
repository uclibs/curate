class Collection < ActiveFedora::Base
  include Hydra::Collection
  include CurationConcern::CollectionModel
  include Hydra::Collections::Collectible
  include Hydra::Derivatives

  has_file_datastream :name => "content"
  has_file_datastream :name => "medium"
  has_file_datastream :name => "thumbnail"

  attr_accessor :mime_type
  attr_accessor :file

  makes_derivatives :generate_derivatives

  before_save :add_profile_image, :only => [ :create, :update ]

  def members_from_solr
    ActiveFedora::Base.find_with_conditions({ collection_sim: self.pid }, { rows: [2000], sort: ['sort_title_ssi asc'] })
  end

  def can_be_member_of_collection?(collection)
    collection == self ? false : true
  end

  def add_profile_image
    if file
      self.content.content = file
      self.mime_type = file.content_type
      generate_derivatives
    end
  end

  def representative_image_url
    generate_thumbnail_url if self.thumbnail.content.present?
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    Solrizer.set_field(solr_doc, 'generic_type', 'Collection', :facetable)
    Solrizer.set_field(solr_doc, 'sort_title', sort_title, :stored_sortable)
    solr_doc[Solrizer.solr_name('representative', :stored_searchable)] = self.representative
    solr_doc[Solrizer.solr_name('representative_image_url', :stored_searchable)] = self.representative_image_url
    solr_doc[Solrizer.solr_name('owner_name', :stored_searchable)] = owner_name(solr_doc['edit_access_person_ssim'])
    solr_doc
  end

  def representative
    to_param
  end

  private

  def sort_title
    unless self.title.nil?
      cleaned_title = self.title.sub(/^\s+/i, "") # remove leading spaces
      cleaned_title.gsub!(/[^\w\s]/, "") # remove punctuation; preserve spaces and A-z 0-9
      cleaned_title.gsub!(/\s{2,}/, " ") # remove multiple spaces
      cleaned_title.sub!(/^(a |an |the )/i, "") # remove leading english articles
      cleaned_title.upcase! #upcase everything
      add_leading_zeros_to cleaned_title
    end
  end

  def add_leading_zeros_to(title)
    leading_number = title.match(/^\d+/)
    return title if leading_number.nil?
    title.sub(/^\d+/, leading_number[0].rjust(20, "0"))
  end

  def generate_derivatives
    case mime_type
    when 'image/png', 'image/jpeg', 'image/tiff'
      transform_datastream :content, { medium: {size: "300x300>", datastream: 'medium'}, thumb: {size: "100x100>", datastream: 'thumbnail'} }
    end
  end

  def generate_thumbnail_url
    "/downloads/#{self.representative}?datastream_id=thumbnail"
  end

  def owner_name(edit_user)
    if user = User.find_by_email(edit_user)
     user.inverted_name
    end
  end
end
