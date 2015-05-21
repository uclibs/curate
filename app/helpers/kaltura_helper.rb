module KalturaHelper
   
  def my_media_list
    @options = { :filter => { :creatorIdEqual => current_user } }
    puts @options
    entries = Kaltura::MediaEntry.list(@options)
    unless entries.blank?
      html = '' 
      entries.each do |item|
        html << 
          content_tag(:li, :id => item.name.gsub(' ', '-').downcase.strip) do
             link_to(image_tag(item.thumbnailUrl, :size =>  "64x64") + "   " + item.name, item.downloadUrl)  
         end
      end
    end
  return html.html_safe
  end

  def kaf_path
#        Kaltura.configure do |config|
#          config.partner_id = 1927411
#          config.userId = current_user
#          config.role = adminRole
#          config.endpoint = My Media
#        end
#    @session = Kaltura::Session.start
#    puts @session
#    iframeURL = "https://scholartest.kaf.kaltura.com/kaftestme/hosted/index/my-media/ks/"+@session
    return "https://scholartest.kaf.kaltura.com/kaftestme/hosted/index/my-media/ks/djJ8MTkyNzQxMXwC0fJHvy3lmjBFm8p1__jLbHNOimuygUhjMauJSGc_s8o4ENI-HOU441RIXVHcMEvDbCeREDhYIa_OY0mbOFN15jcwd5WVXEAexrIhOaYuBE59b2nfdppmYtWIxbZCm-3t4DL60xgmoL-Js5PY5E2zKpb-wyETif9rVVa_A5VCryWL8SThKFeusqgHPLCxG51_ghJjYZz4v7C-lfJyFCaWmUmeFoVH1mHVgviCXgGjmX_S04r88UxmuTq4HuP5jZr139NUGHq3-cPR4hDam2WrspmwNdWgkTOdiZVRyQNDE4z7aVMDLU3tSG5LoE-kNKjMpV-M8tyqGzB6GQ_D2ARuDZcc2_-DgddFREg73ePAwvY5lI4ZucZQML39Z-g8oFLXaFrgx_JLnaOmaKFo7NwB"
  end
end
