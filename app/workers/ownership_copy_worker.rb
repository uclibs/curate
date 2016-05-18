class OwnershipCopyWorker
  class PidError < RuntimeError
    def initialize(url_string)
      super(url_string)
    end
  end
  def queue_name
    :ownership
  end

  attr_accessor :pid

  def initialize(pid)
    if pid.blank?
      raise PidError.new("PID required.")
    end
    self.pid = pid
  end

  def run
    work = ActiveFedora::Base.find(pid, cast: true)
    work.synchronize_link_and_file_ownership
  end
end
