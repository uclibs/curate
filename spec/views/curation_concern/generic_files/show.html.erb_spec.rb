require 'spec_helper'

describe 'curation_concern/generic_files/show.html.erb' do

  before do
    view.stub(:manager_deposit?).and_return(true)
  end

  it 'displays an audio player' do
    file = stub_model(GenericFile, audit_stat: true, pid: '1234')
    allow(view).to receive(:can?) { true }

    render(template: 'curation_concern/generic_files/show', locals: {curation_concern: file, parent: file})
    
    expect(response).to render_template(partial: '_media_display')
  end

  it 'doesnt display depositor if it is a manager' do
    file = stub_model(GenericFile, audit_stat: true, pid: '1234')
    allow(view).to receive(:can?) { true }

    render(template: 'curation_concern/generic_files/show', locals: {curation_concern: file, parent: file})
    
    expect(response).to_not have_content("Depositor")
    expect(response).to have_content("Title")
  end
end
