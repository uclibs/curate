class StudentWork < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithEditorsAndReaders

  include CurationConcern::WithMetaTags
  def special_meta_tag_fields
    %i(description language)
  end

  include ActiveFedora::RegisteredAttributes

  def collections
    Collection.find(
      Collection.find_with_conditions(has_collection_member_ssim: "info:fedora/#{self.pid}").collect do |result|
        result["id"]
      end
    )
  end

  has_metadata "descMetadata", type: StudentWorkRdfDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Deposit any kind of student work."

  has_attributes :unit, :unit_attributes, datastream: :descMetadata, multiple: true

  def build_unit
    descMetadata.unit = [StudentWorkRdfDatastream::Unit.new(RDF::Repository.new)]
  end

  attribute :advisor,
    datastream: :descMetadata, multiple: true

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

  attribute :degree,
    datastream: :descMetadata, multiple: false

  attribute :description,
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
    datastream: :descMetadata, multiple: false

  attribute :files, multiple: true, form: {as: :file}

  def to_solr(solr_doc = {})
    super
    solr_doc[Solrizer.solr_name('desc_metadata__college', :stored_searchable)] = college
    solr_doc[Solrizer.solr_name('desc_metadata__college', :facetable)] = college
    solr_doc[Solrizer.solr_name('desc_metadata__department', :stored_searchable)] = department
    solr_doc[Solrizer.solr_name('desc_metadata__department', :facetable)] = department
    solr_doc[Solrizer.solr_name('human_readable_type', :facetable)] = type
    solr_doc
  end

  def college
    return self.unit.first.college.first unless self.unit.blank?
    nil
  end

  def department
    return self.unit.first.department.first unless self.unit.blank?
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
