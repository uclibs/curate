class FileRequestMailer < ActionMailer::Base

  def notify(email, name, pid)
    mail(from: email,
        to: recipients_list,
        subject: "File request",
        body: prepare_body(email,name, pid)).deliver
  end

  private

  def prepare_body(email,name, pid)
    body = "#{name} (#{email}) would like to request the file at this pid: #{pid}"
    body
  end

  def recipients_list
    return @list if !@list.blank?
    @list = YAML.load(File.open(File.join(Rails.root, "config/recipients_list.yml"))).split(" ")
    return @list
  end
end

