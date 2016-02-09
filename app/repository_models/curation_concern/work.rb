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
      return solr_doc
    end

    def synchronize_link_and_file_permissions
      assets = self.attached_files_and_links
      unless assets.nil?
        assets.each do |asset|
          asset.edit_users = self.edit_users
          asset.read_users = self.read_users
          asset.edit_groups = self.edit_groups
          asset.read_groups = self.read_groups
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

  end
end
