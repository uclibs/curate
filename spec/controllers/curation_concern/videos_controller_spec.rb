# Generated via
#  `rails generate curate:work Video`
require 'spec_helper'

describe CurationConcern::VideosController do
  it_behaves_like 'is_a_curation_concern_controller', Video, actions: :all
end
