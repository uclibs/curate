class CurationConcern::DocumentsController < CurationConcern::GenericWorksController
  self.curation_concern_type = Document

  def setup_form
    super
    curation_concern.build_unit if curation_concern.unit.blank?
  end
end
