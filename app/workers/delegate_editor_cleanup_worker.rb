class DelegateEditorCleanupWorker
  class GrantError < RuntimeError

    def initialize(url_string)
      super(url_string)
    end
  end

  def queue_name
    :de_delegate
  end

  attr_accessor :pids, :grantor, :grantee, :grantor_pid, :grantee_pid

  def initialize(pids)
    if pids[:grantor].nil?
      raise GrantError.new("No Grantor found.")
    end
    if pids[:grantee].nil?
      raise GrantError.new("No Grantee found.")
    end
    @grantor_pid = pids[:grantor]
    @grantee_pid = pids[:grantee]
  end

  def run
    grantor = ActiveFedora::Base.find(@grantor_pid, cast: true)
    grantee = ActiveFedora::Base.find(@grantee_pid, cast: true)

    type = [Article, Dataset, Document, GenericWork, Image]
    type.each do |klass|
      klass.find_each('edit_access_person_ssim' => grantee.email) do |work|
        next unless work.owner != grantee.email
        work.edit_users -= [grantee.email]
        work.editor_ids += [grantor.pid]
        work.editor_ids -= [grantee.pid]
        work.save!

        grantee.work_ids -= [work.pid]
        grantee.save!

        work.synchronize_link_and_file_permissions
      end
    end
  end
end
