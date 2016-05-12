require 'spec_helper'

describe ChangeOwnerController do 

	describe '#update' do
    let(:new_person) {FactoryGirl.create(:person_with_user)}
    let(:creating_person) { FactoryGirl.create(:person_with_user) }
    let!(:work) {FactoryGirl.create_curation_concern(:generic_work, creating_person.user)}
    
    before do
      controller.stub(:new_owner).and_return(new_person)
      controller.stub(:old_owner).and_return(creating_person)
      controller.stub(:work).and_return(work)
    end

    it "should change the owner and edit permissions of the work" do
      post :update, work_pid: work.pid, user: "Sue Jones (#{new_person.email})"
      work.owner.should == new_person.email
    end

    it "should add two workers to the queue" do
      access_worker = double
      owner_worker = double

      OwnershipCopyWorker.should_receive(:new).with(work.pid).and_return(owner_worker)
      AccessPermissionsCopyWorker.should_receive(:new).with(work.pid).and_return(access_worker)

      Sufia.queue.should_receive(:push).with(owner_worker)
      Sufia.queue.should_receive(:push).with(access_worker)

      post :update, work_pid: work.pid, user: "Sue Jones (#{new_person.email})" 
    end
	end
end