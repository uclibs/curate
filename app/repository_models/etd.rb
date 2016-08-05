class Etd < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithEditorsAndReaders

  include CurationConcern::WithMetaTags
  def special_meta_tag_fields
    %i(abstract language)
  end

  include ActiveFedora::RegisteredAttributes

  has_metadata "descMetadata", type: EtdDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Must be submitted by the UC Graduate School"

  class_attribute :human_readable_type
  self.human_readable_type = "Thesis or Dissertation"

  self.indefinite_article = 'an'

  attribute :abstract,
    datastream: :descMetadata, multiple: false

  attribute :advisor,
    datastream: :descMetadata, multiple: false

  attribute :alternate_title,
    datastream: :descMetadata, multiple: true

  attribute :bibliographic_citation,
    datastream: :descMetadata, multiple: false

  attribute :college,
    datastream: :descMetadata, multiple: false

  attribute :contributor,
    datastream: :descMetadata, multiple: true

  attribute :coverage_spatial,
    datastream: :descMetadata, multiple: true

  attribute :coverage_temporal,
    datastream: :descMetadata, multiple: true

  attribute :creator,
    datastream: :descMetadata, multiple: true
  
  attribute :date_created,
    datastream: :descMetadata, multiple: false

  attribute :committee_member,
    datastream: :descMetadata, multiple: true

  attribute :date_modified, 
    datastream: :descMetadata, multiple: false

  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false

  attribute :degree,
    datastream: :descMetadata, multiple: false

  attribute :department,
    datastream: :descMetadata, multiple: false

  attribute :genre,
    datastream: :descMetadata, multiple: false

  attribute :identifier,
    datastream: :descMetadata, multiple: false,
    editable: false

  attribute :language,
    datastream: :descMetadata, multiple: true

  attribute :note,
    datastream: :descMetadata, multiple: false,
    editable: true

  attribute :publisher,
    datastream: :descMetadata, multiple: false,
    default: "University of Cincinnati",
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

  attribute :source,
    datastream: :descMetadata, multiple: false

  attribute :subject,
    datastream: :descMetadata, multiple: true

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'Your article must have a title.' } }

  attribute :type,
    datastream: :descMetadata, multiple: false,
    default: "Text"

  attribute :files, multiple: true, form: {as: :file}

  def degree_for_display
    field = []
    field << self.date_created unless self.date_created.blank?
    field << self.degree unless self.degree.blank?
    field << self.publisher unless self.publisher.blank?
    field << self.unit_for_display unless self.unit_for_display.nil?
    return field.join(", ") unless field.empty?
    nil
  end

  def unit_for_display
    if self.college.blank?
      if self.department.blank?
        nil
      else
        self.department
      end
    else
      if self.department.blank?
        self.college
      else
        self.college + " : " + self.department
      end
    end
  end
end
