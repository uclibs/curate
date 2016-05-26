class Video < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithEditorsAndReaders

  include CurationConcern::WithMetaTags

  def special_meta_tag_fields
    %i(description language date_digitized)
  end

  include ActiveFedora::RegisteredAttributes

  def collections
    Collection.find(
      Collection.find_with_conditions(has_collection_member_ssim: "info:fedora/#{self.pid}").collect do |result|
        result["id"]
      end
    )
  end

  has_metadata "descMetadata", type: VideoRdfDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Works that include video, film, slide, or audio are referred to as time-based media."

  attribute :alternate_title,
    datastream: :descMetadata, multiple: true

  attribute :bibliographic_citation,
    datastream: :descMetadata, multiple: false

  attribute :contributor,
    datastream: :descMetadata, multiple: true

  attribute :coverage_spatial,
    datastream: :descMetadata, multiple: true

  attribute :coverage_temporal,
    datastream: :descMetadata, multiple: true

  attribute :date_created,
    datastream: :descMetadata, multiple: false

  attribute :creator,
    datastream: :descMetadata, multiple: true
  
  attribute :date_modified, 
    datastream: :descMetadata, multiple: false

  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false

  attribute :date_digitized,
    datastream: :descMetadata, multiple: false

  attribute :description,
    datastream: :descMetadata, multiple: false

  attribute :identifier,
    datastream: :descMetadata, multiple: false,
    editable: false

  attribute :language,
    default: ['English'],
    datastream: :descMetadata, multiple: true

  attribute :note,
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :publisher,
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :publisher_digital,
    default: "University of Cincinnati",
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :requires,
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :rights,
    datastream: :descMetadata, multiple: false,
    default: "All rights reserved",
    validates: { presence: { message: 'You must select a license for your work.' } }

  attribute :subject,
    datastream: :descMetadata, multiple: true

  attribute :type,
    datastream: :descMetadata, multiple: false

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'Your article must have a title.' } }

  attribute :files, multiple: true, form: {as: :file}
end
