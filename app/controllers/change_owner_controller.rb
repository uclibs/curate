class ChangeOwnerController < ApplicationController

  def update
    remove_delegate_access(old_owner)

    work.add_editor(new_owner.user)

    work.owner = new_owner_email
    
    work.remove_editor(old_owner.user)

    work.save

    new_owner.editable_work_ids += [work.pid]
    new_owner.save

    old_owner.editable_work_ids -= [work.pid]
    old_owner.save

    Sufia.queue.push(OwnershipCopyWorker.new(work.pid))
    Sufia.queue.push(AccessPermissionsCopyWorker.new(work.pid))

    redirect_to :back, notice: "Succesfully changed the owner from #{old_owner} to #{new_owner}! Please give files a minute to synchronize."
  end

  private

  def remove_delegate_access(old_owner)
    old_owner.user.can_receive_deposits_from.each do |dep|
      dep_person = person_lookup(dep.email)
      work.edit_users -= [dep_person.email]
      work.editor_ids -= [dep_person.pid]

      dep_person.editable_work_ids -= [work.pid]
      dep_person.save
    end
  end

  def new_owner_email
    temp_email = params[:user].reverse
    @email = temp_email[1..temp_email.index('(')-1]
    @email.reverse!
  end

  def new_owner
    @new_owner ||= person_lookup(new_owner_email)
  end

  def old_owner
    @old_owner ||= person_lookup(work.owner)
  end

  def person_lookup(email)
    Person.find(depositor: email).first
  end

  def work
    @work ||= ActiveFedora::Base.find(pid: params[:work_pid]).first
  end
end