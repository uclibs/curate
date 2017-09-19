class FilesReport < Report

  private

  def self.report_objects
    GenericFile.all
  end

  def self.fields(file = GenericFile.new)
    [ 
      { pid: file.pid },
      { title: file.label },
      { filename: file.filename },
      { date_uploaded: file.date_uploaded.to_s },
      { visibility: file.visibility },
      { embargo_release_date: file.embargo_release_date },
      { owner: file.owner },
      { depositor: file.depositor },
      { edit_users: file.edit_users.join("|") },
    ]
  end
end
