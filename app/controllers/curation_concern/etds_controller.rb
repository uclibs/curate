class CurationConcern::EtdsController < CurationConcern::GenericWorksController
  before_action :etd_manager_restriction, only: [:new, :create]
  self.curation_concern_type = Etd

  def setup_form
    curation_concern.editors << current_user.person if curation_concern.editors.blank?
    curation_concern.editors.build
    curation_concern.readers.build
    curation_concern.editor_groups.build
    curation_concern.reader_groups.build
  end

  private

  def etd_manager_restriction
    unless can? :create, Etd
      render(:file => File.join(Rails.root, 'public/404.html'), :status => 404)
    end
  end
end
