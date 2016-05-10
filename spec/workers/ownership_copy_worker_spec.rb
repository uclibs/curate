require 'spec_helper'

describe OwnershipCopyWorker do
  context 'for blank pid' do
    it 'raise error' do
      expect{
        OwnershipCopyWorker.new(nil)
      }.to raise_error( OwnershipCopyWorker::PidError )
    end
  end

  context 'for valid pid' do
    let(:work) { double(GenericWork, pid: 'foo:123') }
    let(:pid) { work.pid }

    before do
      ActiveFedora::Base.stub(:find).and_return(work)
    end

    it 'call Work.synchronize_link_and_file_ownership' do
      AccessPermissionsCopyWorker.new(pid).run
      expect(work).to have_received(:synchronize_link_and_file_ownership)
    end
  end
end
