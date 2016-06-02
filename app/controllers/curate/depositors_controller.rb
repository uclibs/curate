class Curate::DepositorsController < ApplicationController
  include Sufia::Noid # for normalize_identifier method

  with_themed_layout
  prepend_before_filter :normalize_identifier
  before_filter :authenticate_user!
  before_filter :load_grantor

  def index
  end

  def create
    response = {}
    unless params[:person_id] == params[:grantee_id]
      grantor = Person.find(params[:person_id])
      authorize! :edit, grantor
      grantee = Person.find(params[:grantee_id])

      unless grantor.user.can_receive_deposits_from.include? (grantee.user)
        grantor.user.can_receive_deposits_from << grantee.user
        response = {name: grantee.name, delete_path: person_depositor_path(grantor, grantee) }
        Sufia.queue.push(DelegateEditorAssignWorker.new(pids_for_delegate_assign))
      end

      respond_to do |format|
        format.json { render json: response}
      end
    CurateManager.queue_change(grantor.email, 'added_as_delegate', '', grantee.email)
    end
  end

  def destroy
    grantor = Person.find(params[:person_id])
    grantee = Person.find(params[:id])
    authorize! :edit, grantor
    grantor.user.can_receive_deposits_from.delete(grantee.user)
    CurateManager.queue_change(grantor.email, 'removed_as_delegate', '', grantee.email)
    Sufia.queue.push(DelegateEditorCleanupWorker.new(pids_for_grantee_grantor))    

    respond_to do |format|
      format.json { head :no_content }
    end    
  end

  protected

  def pids_for_grantee_grantor
    {grantor: params[:person_id], grantee: params[:id]}
  end	
  
  def pids_for_delegate_assign
    {grantor: params[:person_id], grantee: params[:grantee_id]}
  end

  def load_grantor
    @grantor = Person.find(params[:person_id])
    authorize! :edit, @grantor
  end

  def normalize_identifier
    params[:person_id] = Sufia::Noid.namespaceize(params[:person_id])
    super if params[:id]
  end

end
