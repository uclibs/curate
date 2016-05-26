class CurationConcern::DatasetsController < CurationConcern::GenericWorksController
  self.curation_concern_type = Dataset

  def setup_form
    super
    curation_concern.build_unit if curation_concern.unit.blank?
  end
end
