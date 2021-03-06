module CurationConcern
  module Work
    extend ActiveSupport::Concern
    
    # Parses a comma-separated string of tokens, returning an array of ids
    def self.ids_from_tokens(tokens)
      tokens.gsub(/\s+/, "").split(',')
    end

    unless included_modules.include?(CurationConcern::Model)
      include CurationConcern::Model
    end
    include Hydra::AccessControls::Permissions

    def to_solr(solr_doc={}, opts={})
      super(solr_doc, opts)
      Solrizer.set_field(solr_doc, 'generic_type', 'Work', :facetable)
      Solrizer.set_field(solr_doc, 'sort_title', sort_title, :stored_sortable)
      return solr_doc
    end

    def doi_status
      if self.visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC 
        "public"
      else
        if self.locally_managed_remote_identifier?
          "unavailable"
        else
          "reserved"
        end
      end
    end

    def locally_managed_remote_identifier?
      return true unless self.identifier_url.nil?
      false
    end

    def synchronize_link_and_file_permissions
      assets = self.attached_files_and_links
      unless assets.nil?
        assets.each do |asset|
          access = file_read_access(asset)
          asset.edit_users = self.edit_users
          asset.read_users = self.read_users
          asset.edit_groups = self.edit_groups
          asset.read_groups = filter_read_groups
          asset.read_groups += access
          asset.save!
        end
      end
    end

    def synchronize_link_and_file_ownership
      assets = self.attached_files_and_links
      unless assets.nil?
        assets.each do |asset|
          asset.owner = self.owner
          asset.save!
        end
      end
    end

    def attached_files_and_links
      files = self.generic_files
      links = self.linked_resources
      return nil if files.blank? and links.blank?
      return links if files.nil? 
      return files if links.nil? 
      files + links
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

    def filter_read_groups
      filtered = self.read_groups
      filtered -= ['public']
      filtered -= ['registered']
      filtered
    end

    def file_read_access(file)
      if file.read_groups.include?("public")
        return ["public"]
      elsif file.read_groups.include?("registered")
        return ["registered"]
      else
        return []
      end
    end
  end
end
