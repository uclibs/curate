class CurationConcern::ArticlesController < CurationConcern::GenericWorksController
  self.curation_concern_type = Article

  def setup_form
    super
    curation_concern.build_unit if curation_concern.unit.blank?
  end

end
