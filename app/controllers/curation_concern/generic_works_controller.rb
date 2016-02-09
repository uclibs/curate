class CurationConcern::GenericWorksController < CurationConcern::BaseController
  respond_to(:html)
  with_themed_layout '1_column'
  before_filter :remove_viral_files, only: [:create]

  def remove_viral_files
    viral_files = []
    clam = ClamAV.instance
    content = attributes_for_actor

    unless content.nil? or content["files"].nil?
      file_attributes = content["files"].collect do |file|
        {file_name: file.original_filename, temp_path: file.tempfile.path }
      end

      scan_result = file_attributes.collect do |file|
        { result: clam.scanfile(file[:temp_path]), file_name: file[:file_name] }
      end

      scan_result.each do |file_scan|
        viral_files << file_scan[:file_name] unless file_scan[:result].is_a? Fixnum
      end

      if viral_files.any?
        flash[:error] = "A virus was detected in the file #{viral_files.first}. Your work was created, but no files were attached. Please review your files and re-attach."
        content["files"]=nil
      end
    end
  end

  def new
    setup_form
  end

  def create
    return unless verify_acceptance_of_user_agreement!
    if actor.create
      after_create_response

      #If the owner is still hidden, make them public
      work_owner = Person.where(depositor: curation_concern.owner).first
      if work_owner.read_groups.empty?
        work_owner.read_groups = ['make_public']
        work_owner.save!
        work_owner.to_solr
      end

    else
      setup_form
      flash[:error] = "A virus/error was found in one of the uploaded files.  The file was not uploaded, but the work was created."
      respond_with([:curation_concern, curation_concern]) do |wants|
        wants.html { render 'show', status: :unprocessable_entity }
      end
    end
  end

  def after_create_response
    respond_with([:curation_concern, curation_concern])
  end
  protected :after_create_response

  # Override setup_form in concrete controllers to get the form ready for display
  def setup_form
    if curation_concern.respond_to?(:creator)
      curation_concern.creator << current_user.inverted_name if curation_concern.creator.empty? && !current_user.can_make_deposits_for.any?
    end

    curation_concern.editors << current_user.person if curation_concern.editors.blank?
    curation_concern.editors.build
    curation_concern.readers.build
    curation_concern.editor_groups.build
    curation_concern.reader_groups.build
  end
  protected :setup_form

  def verify_acceptance_of_user_agreement!
    if contributor_agreement.is_being_accepted?
      return true
    else
      # Calling the new action to make sure we are doing our best to preserve
      # the input values; Its a stretch but hopefully it'll work
      self.new
      respond_with([:curation_concern, curation_concern]) do |wants|
        wants.html {
          flash.now[:error] = "You must accept the distribution agreement"
          render 'new', status: :conflict
        }
      end
      return false
    end
  end
  protected :verify_acceptance_of_user_agreement!

  def show
    respond_with(curation_concern)
  end

  def edit
    setup_form
    respond_with(curation_concern)
  end

  def update
    if actor.update
      after_update_response
    else
      setup_form
      respond_with([:curation_concern, curation_concern]) do |wants|
        wants.html { render 'edit', status: :unprocessable_entity }
      end
    end
  end

  def after_update_response
    if actor.visibility_changed?
      redirect_to confirm_curation_concern_permission_path(curation_concern)
    else
      respond_with([:curation_concern, curation_concern])
    end
  end
  protected :after_update_response

  def destroy
    title = curation_concern.to_s
    curation_concern.destroy
    after_destroy_response(title)
  end

  def after_destroy_response(title)
    flash[:notice] = "Deleted #{title}"
    respond_with { |wants|
      wants.html { redirect_to catalog_index_path }
    }
  end
  protected :after_destroy_response

  register :actor do
    CurationConcern.actor(curation_concern, current_user, attributes_for_actor)
  end

  def attributes_for_actor
    return params[hash_key_for_curation_concern] if cloud_resources_to_ingest.nil?
    params[hash_key_for_curation_concern].merge!(:cloud_resources=>cloud_resources_to_ingest)
  end

  def hash_key_for_curation_concern
    curation_concern_type.name.underscore.to_sym
  end
end
