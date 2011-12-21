require 'spec_helper'

describe Absa::H2h::Transmission::Eft::Header do
  
  before(:each) do
    @hash = {
      transmission: {
        header: {},
        trailer: {},
        sections: [{
          type: 'eft',
          content: {
            header: {
              rec_id: "001",
              rec_status: "T",
              bankserv_record_identifier: "04",
              bankserv_user_code: "9534",
              bankserv_creation_date: Time.now.strftime("%y%m%d"),
              bankserv_purge_date: Time.now.strftime("%y%m%d"),
              first_action_date: Time.now.strftime("%y%m%d"),
              last_action_date: Time.now.strftime("%y%m%d"),
              first_sequence_number: "1",
              user_generation_number: "37",
              type_of_service: "CORPSSV",
            },
          }
        }]
      }
    }
    @eft_header = @hash[:transmission][:sections].first[:content][:header]
  end
  
  it "should be able to build a document header" do
    header = Absa::H2h::Transmission::Eft::Header.new(@eft_header)
    today = Time.now.strftime("%y%m%d")
    
    string = " " * 198 + "\r\n"
    string[0,51] = "001T049534#{today}#{today}#{today}#{today}0000010037CORPSSV"
    
    header.to_s.should == string
  end
  
  it "should raise an exception if a provided field exceeds the allowed length" do
    @eft_header[:rec_id] = "0000"
    lambda {document = Absa::H2h::Transmission::Eft::Header.new(@eft_header)}.should raise_error("rec_id: Input too long")
  end
  
  it "should raise an exception if a provided field is not a specified type" do
    @eft_header[:type_of_service] = "SAVINGS"
    lambda {document = Absa::H2h::Transmission::Eft::Header.new(@eft_header)}.should raise_error("type_of_service: Invalid data")
  end

  
end