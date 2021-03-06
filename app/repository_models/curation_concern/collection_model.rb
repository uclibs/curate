module CurationConcern
  module CollectionModel
    extend ActiveSupport::Concern

    include Hydra::AccessControls::Permissions
    include Hydra::AccessControls::WithAccessRight
    include Sufia::Noid
    include CurationConcern::HumanReadableType

    def add_member(collectible)
      if can_add_to_members?(collectible)
        collectible.collections << self
        collectible.save
        self.members << collectible
        self.save
      end
    end

    def remove_member(collectible)
      return false unless self.members.include?(collectible)
      collectible.collections.delete(self)
      collectible.save
      self.members.delete(collectible)
      self.save
    end

    def to_s
      self.title.present? ? title : "No Title"
    end

    def to_solr(solr_doc={}, opts={})
      super
      Solrizer.set_field(solr_doc, 'generic_type', human_readable_type, :facetable)
      index_collection_pids(solr_doc)
      solr_doc
    end

    def index_collection_pids(solr_doc)
      solr_doc[Solrizer.solr_name(:collection, :facetable)] ||= []
      solr_doc[Solrizer.solr_name(:collection)] ||= []
      self.collection_ids.each do |collection_id|
        collection_obj = ActiveFedora::Base.load_instance_from_solr(collection_id)
        if collection_obj.is_a?(Collection)
          solr_doc[Solrizer.solr_name(:collection, :facetable)] << collection_id
          solr_doc[Solrizer.solr_name(:collection)] << collection_id
        end
      end
      solr_doc
    end

    # ------------------------------------------------
    # overriding method from active-fedora:
    # lib/active_fedora/semantic_node.rb
    #
    # The purpose of this override is to ensure that
    # a collection cannot contain itself.
    #
    # TODO:  After active-fedora 7.0 is released, this
    # logic can be moved into a before_add callback.
    # ------------------------------------------------
    def add_relationship(predicate, target, literal=false)
      return if self == target
      super
    end

    private
    def can_add_to_members?(collectible)
      collectible.can_be_member_of_collection?(self)
    rescue NoMethodError
      false
    end

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
  end
end
