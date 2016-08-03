class FileRequestsController < ApplicationController
  SUCCESS_NOTICE = "Thank you.  Your request has been sent to the Scholar@UC team."
  FAIL_NOTICE = "You must complete the Captcha to confirm the form."
 
  def new
    @file_pid ||= params[:pid]
    file = GenericFile.find(pid: "sufia:" + @file_pid).first
    @file_name = file.title.first
  end
 
  def verify_google_recaptcha(key,response)
    status = `curl "https://www.google.com/recaptcha/api/siteverify?secret=#{CAPTCHA_SERVER['secret_key']}&response=#{response}"`
    hash = JSON.parse(status)
    hash["success"] == true ? true : false
   end
 
  def create
    @name = params[:name]
    @email = params[:email]
    @file_pid = params[:file_pid]

    if passes_catcha_or_is_logged_in?
      FileRequestMailer.notify(@email,@name,@file_pid)
      redirect_to catalog_index_path, notice: SUCCESS_NOTICE
    else
      flash.now[:notice] = FAIL_NOTICE
      render :action => 'new'
    end
  end

  private

  def passes_catcha_or_is_logged_in?
    if current_user.present?
      return true
    else
      return verify_google_recaptcha(CAPTCHA_SERVER['secret_key'],params["g-recaptcha-response"])
    end
  end
end