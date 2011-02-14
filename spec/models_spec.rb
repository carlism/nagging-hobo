require 'spec_helper'
require 'models'
require 'nokogiri'

describe NaggingHobo::Model::Job do
  before(:each) do
    @job = NaggingHobo::Model::Job.create_from_xml(load_fixture('new_job.xml'))
  end

  describe "create_from_xml" do
    it "should create a job with the right field values" do
      @job.name.should == "test_name"
      @job.email.should == Digest::MD5.hexdigest("carl.leiby@gmail.com")
      @job.message.should == "test_message"
      @job.trigger_at.should == DateTime.parse("2011-02-12T00:00:00-05:00")
    end
  end

  describe "to_xml" do
    it "should produce correct xml from a job" do
      doc = Nokogiri::XML(@job.to_xml)
      [:id, :moment_id, :name, :message,
       :email, :complete, :trigger_at].each do |tag|
        doc.at(tag).should_not be nil
      end
      doc.at(:name).content.should == "test_name"
      doc.at(:message).content.should == "test_message"
      doc.at(:email).content.should == "22f3735be3b6f372d7452f5a6b2bbfbe"
      doc.at(:complete).content.should == "false"
      doc.at(:trigger_at).content.should == "2011-02-12T00:00:00-05:00"
    end
  end
end