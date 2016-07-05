require 'spec_helper'

describe FileRequestsController do
  describe 'GET #new' do
    let(:file) {double('GenericFile', title: ["Big large file"])}
    before do
      GenericFile.stub(:find).and_return([file])
    end
    it 'is allowed when not logged in' do
      get :new, pid: '123456'
      expect(response.status).to eq(200)
      expect(response).to render_template('new')
    end
  end

  context 'POST #create' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      controller.params[:name] = "Joe Shmo"
      controller.params[:email] = "joe@hotmail.com" 
      controller.params[:file_pid] =  "123456"
      FileRequestMailer.stub(:notify).and_return(true)
    end

    describe 'success' do
      it 'redirects to dashboard and flashes a message' do
        sign_in(user)
        post(:create)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(catalog_index_path)
      end
    end
    describe 'failure' do
      before do
        controller.stub(:passes_catcha_or_is_logged_in?).and_return(false)
      end
      it 're-renders the form' do
        post(:create)
        expect(response.status).to eq(200)
        expect(response).to render_template('new')
      end
    end
  end
end