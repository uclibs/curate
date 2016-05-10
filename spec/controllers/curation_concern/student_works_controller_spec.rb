require 'spec_helper'

describe CurationConcern::StudentWorksController do
  it_behaves_like 'is_a_curation_concern_controller', StudentWork, actions: :all
end
