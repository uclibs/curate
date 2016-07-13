require 'spec_helper'

describe User do
  subject { FactoryGirl.build :user }

  describe "proxy_deposit_rights" do
    let(:user1) { FactoryGirl.create :user }
    let(:user2) { FactoryGirl.create :user }
    before do
      subject.can_receive_deposits_from << user1
      subject.can_make_deposits_for << user2
      subject.save!
    end
    it "can_receive_deposits_from" do
      subject.can_receive_deposits_from.should == [user1]
      user1.can_make_deposits_for.should == [subject]
    end
    it "can_make_deposits_for" do
      subject.can_make_deposits_for.should == [user2]
      user2.can_receive_deposits_from.should == [subject]
    end
  end

  describe "#etd_manager?" do
    it 'should be true if user is a repository manager' do
      subject.stub(:manager?).and_return(true)
      expect(subject.etd_manager?).to be_true
    end

    it 'should be true if user is in etd_manager config' do
      subject.stub(:user_key).and_return("etd_manager@example.com")
      expect(subject.etd_manager?).to be_true
    end

    it 'should be false if user is not in etd_manager config' do
      subject.stub(:user_key).and_return("regular_user@example.com")
      expect(subject.etd_manager?).to be_false
    end

    it 'should be true if user can make deposits for an etd_manager' do
      subject.stub(:can_make_deposits_for)
        .and_return([OpenStruct.new(email: "etd_manager@example.com")])
      expect(subject.etd_manager?).to be_true
    end
  end

  describe "#college" do
    it "returns 'Other' if #ucdepartment is nil" do
      subject.stub(:ucdepartment).and_return(nil)
      expect(subject.college).to eq('Other')
    end

    it "returns the college name if #ucdepartment begins with a matching abbreviation" do
      subject.stub(:ucdepartment).and_return("COM Internal Medicine")
      expect(subject.college).to eq('Medicine')
    end

    it "returns 'Other' if #ucdepartment doesn't begin with a matching abbreviation" do
      subject.stub(:ucdepartment).and_return("Foo Internal Medicine")
      expect(subject.college).to eq('Other')
    end
  end

  describe "#department" do
    it "returns 'Unknown' if #ucdepartment is nil" do
      subject.stub(:ucdepartment).and_return(nil)
      expect(subject.department).to eq("Unknown")
    end

    it "returns everything after the first word if #ucdepartment begins with a matching abbreviation" do
      subject.stub(:ucdepartment).and_return("UCL E-resources")
      expect(subject.department).to eq("E-resources")
    end

    it "returns #ucdepartment if #ucdepartment doesn't begin with a matching abbreviation" do
      subject.stub(:ucdepartment).and_return("Foo Internal Medicine")
      expect(subject.department).to eq(subject.ucdepartment)
    end
  end
end
