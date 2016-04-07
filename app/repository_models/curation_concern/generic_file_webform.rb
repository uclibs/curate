module CurationConcern::GenericFileWebform
  extend ActiveSupport::Concern
  
  def to_jq_upload
    return {
      "name" => self.title,
      "size" => self.file_size,
      "url" => "/concern/generic_files/#{noid}",
      "thumbnail_url" => self.pid,
      "delete_url" => "deleteme", # generic_file_path(:id => id),
      "delete_type" => "DELETE"
    }
  end
end
