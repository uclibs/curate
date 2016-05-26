class CurationConcern::VideosController < CurationConcern::GenericWorksController
  self.curation_concern_type = Video

  def setup_form
    super
    curation_concern.build_unit if curation_concern.unit.blank?
  end

  def discover_kaltura_media
    kaltura_userId = @current_user.email

    entries = Kaltura::MediaEntry.list
     
    entries.each do |e|
       e.find_each('userID' => kaltura_userId) do |echo|
         puts echo
       end
    end
  end
end

