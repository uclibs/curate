require 'spec_helper'

describe Curate::PeopleController do
  describe "#show" do
    let(:person) { FactoryGirl.create(:person_with_user) }
    context 'my own person page' do
      before { sign_in person.user }

      it "should show me the page" do
        get :show, id: person.pid
        expect(response).to be_success
        assigns(:person).should == person
      end
    end

    context 'someone elses person page' do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it "should show me the page" do
        get :show, id: person.pid
        expect(response).to be_success
      end
    end
  end

  describe "searching via json" do
    before(:each) do
      @katie = FactoryGirl.create(:person, first_name: 'Katie F.', last_name: 'White-Kopp', email: "katie@example.com")
      @alvin = FactoryGirl.create(:person, first_name: 'A. S.', last_name: 'Mitchell', email: "as@example.com")
      @john = FactoryGirl.create(:person_with_user, first_name: 'John', last_name: 'Corcoran III', email: "john@example.com")
    end

    it "should return results on full first name match" do
      get :index, q: 'Katie', format: :json
      json = JSON.parse(response.body)
      json['response']['docs'].should == [{"id"=>@katie.pid, "desc_metadata__first_name_tesim"=>["Katie F."], "desc_metadata__last_name_tesim"=>["White-Kopp"], "desc_metadata__email_tesim"=>["katie@example.com"]}]
    end

    it "should return results on full last name match" do
      get :index, q: 'Mitchell', format: :json
      json = JSON.parse(response.body)
      json['response']['docs'].should == [{"id"=>@alvin.pid, "desc_metadata__first_name_tesim"=>["A. S."], "desc_metadata__last_name_tesim"=>["Mitchell"], "desc_metadata__email_tesim"=>["as@example.com"]}]
    end

    it "should return results on full email match" do
      get :index, q: 'as@example.com', format: :json
      json = JSON.parse(response.body)
      json['response']['docs'].should == [{"id"=>@alvin.pid, "desc_metadata__first_name_tesim"=>["A. S."], "desc_metadata__last_name_tesim"=>["Mitchell"], "desc_metadata__email_tesim"=>["as@example.com"]}]
    end

    describe "when constrained to users" do
      it "should return users" do
        get :index, q: '', user: true, format: :json
        json = JSON.parse(response.body)
        json['response']['docs'].should == [{"id"=>@john.pid, "desc_metadata__first_name_tesim"=>["John"], "desc_metadata__last_name_tesim"=>["Corcoran III"], "desc_metadata__email_tesim"=>["john@example.com"]}]
      end
    end


  end
end
