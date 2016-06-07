require 'spec_helper'

describe CurationConcern::EtdsController do
  before(:each) { subject.stub(:etd_manager_restriction).and_return(true) }
  it_behaves_like 'is_a_curation_concern_controller', Etd, actions: :all
end
