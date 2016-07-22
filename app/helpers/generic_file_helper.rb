module GenericFileHelper

  def generic_file_title(gf)
    can?(:read, gf) ? gf.to_s : "File"
  end

  def generic_file_link_name(gf)
    can?(:read, gf) ? gf.filename : "File"
  end

  def manager_deposit?(gf)
  	Person.find(depositor: curation_concern.depositor).first.user.manager?
  end

end
