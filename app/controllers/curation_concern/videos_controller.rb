class CurationConcern::VideosController < CurationConcern::GenericWorksController
  self.curation_concern_type = Video

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

