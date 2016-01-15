module CurationConcern
  module WithMetaTags
    extend ActiveSupport::Concern

    def meta_tags
      @tags = Hash.new
      meta_tag_fields.each { |field| descriptive_meta_tag_mapping(field) }
      add_meta_tag('citation_public_url', Curate.permanent_url_for(self))
      add_meta_tag('citation_pdf_url', attached_pdfs)
      @tags
    end

    private 

    def meta_tag_fields
      (%i(bibliographic_citation coverage_spatial coverage_temporal
         creator date_created date_modified
         date_uploaded date_digitzed identifier publisher
         requires subject title) + special_meta_tag_fields).uniq
    end

    def descriptive_meta_tag_mapping(field)
      return if self.send(field).blank?

      case field
      when :abstract
        add_meta_tag('DC.Description', self.send(field))
        add_meta_tag('DC.Description.Abstract', self.send(field))
      when :bibliographic_citation
        add_meta_tag('DC.identifier.bibliographicCitation', self.send(field))
      when :coverage_spatial
        add_meta_tag('DC.Coverage', self.send(field))
        add_meta_tag('DC.Coverage.Spatial', self.send(field))
      when :coverage_temporal
        add_meta_tag('DC.Coverage', self.send(field))
        add_meta_tag('DC.Coverage.Temporal', self.send(field))
      when :creator
        add_meta_tag('author', self.send(field).join('|'))
        add_meta_tag('citation_author', self.send(field))
        add_meta_tag('DC.Creator', self.send(field))
      when :date_created
        add_meta_tag('citation_date', self.send(field))
        add_meta_tag('citation_publication_date', self.send(field))
        add_meta_tag('DC.Date', self.send(field))
        add_meta_tag('DC.Date.Created', self.send(field))
      when :date_modified
        add_meta_tag('DC.Date.Modified', self.send(field))
      when :date_uploaded
        add_meta_tag('DC.Date.dateSubmitted', self.send(field))
      when :date_digitized
        add_meta_tag('citation_digitized', self.send(field))
      when :description
        add_meta_tag('DC.Description', self.send(field))
      when :identifier
        add_meta_tag('citation_doi', self.send(field))
        add_meta_tag('DC.Identifier', self.send(field))
      when :issn
        add_meta_tag('citation_issn', self.send(field))
      when :journal_title
        add_meta_tag('citation_journal_title', self.send(field))
      when :language
        add_meta_tag('citation_language', self.send(field))
        add_meta_tag('DC.Language', self.send(field))
      when :material
        add_meta_tag('DC.Format.Medium', self.send(field))
      when :measurements
        add_meta_tag('DC.Format.Extent', self.send(field))
      when :publisher
        add_meta_tag('citation_publisher', self.send(field))
        add_meta_tag('DC.Publisher', self.send(field))
      when :requires
        add_meta_tag('DC.Relation', self.send(field))
        add_meta_tag('DC.Relation.Requires', self.send(field))
      when :subject
        add_meta_tag('citation_keywords', self.send(field))
        add_meta_tag('DC.Subject', self.send(field))
      when :title
        add_meta_tag('citation_title', self.send(field))
        add_meta_tag('DC.Title', self.send(field))
      end
    end

    def add_meta_tag(label, value)
      if @tags.has_key?(label)
        if value.is_a? Array
          @tags[label] = @tags[label] + value
        else
          @tags[label] << value
        end
      else
        if value.is_a? Array
          @tags[label] = value
        else
          @tags[label] = [value]
        end
      end
    end

    def attached_pdfs
      value = Array.new
      self.generic_files.each do |f|
        value << Curate.download_url_for(f) if f.filename =~ /\.pdf$/
      end
      value
    end
  end
end
