module CurationConcern
  module WithCollegeAndDepartment
    extend ActiveSupport::Concern

    def build_unit
      descMetadata.unit = [descMetadata.class::Unit.new(RDF::Repository.new)]
    end

    def to_solr(solr_doc = {})
      super
      solr_doc[Solrizer.solr_name('desc_metadata__college', :stored_searchable)] = college
      solr_doc[Solrizer.solr_name('desc_metadata__college', :facetable)] = college
      solr_doc[Solrizer.solr_name('desc_metadata__department', :stored_searchable)] = department
      solr_doc[Solrizer.solr_name('desc_metadata__department', :facetable)] = department
      solr_doc
    end

    def college
      self.unit.first.college.first
    end

    def department
      self.unit.first.department.first
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
end
