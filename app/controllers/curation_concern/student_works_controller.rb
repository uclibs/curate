class CurationConcern::StudentWorksController < CurationConcern::GenericWorksController
  self.curation_concern_type = StudentWork

  def setup_form
    super
    curation_concern.build_unit if curation_concern.unit.blank?
  end
end
