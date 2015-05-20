module KalturaHelper
   
  def my_media_list
    @options = { :filter => { :creatorIdEqual => "scherztc" } }
#    entries = Kaltura::MediaEntry.fetch('media', 'get', @options).first.objects.item.map { |item| Kaltura::MediaEntry.new(item) }
    entries = Kaltura::MediaEntry.list(@options)
    entries.each do |item|
      puts item.name
    end
  end

end
