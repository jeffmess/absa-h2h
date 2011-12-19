require 'spec_helper'

describe Absa::H2h do
  
  before(:each) do
    @hash = {
      transmission: {
        header: {
          rec_id: "000",
          th_rec_status: "T",
          th_date: Time.now.strftime("%Y%m%d"),
          th_client_code: "345",
          th_client_name: "DOUGLAS ANDERSON",
          th_transmission_no: "1234567",
          th_for_use_of_ld_user: "Special Token Here",
          th_destination: ""
        }
      }
    }
  end
  
  it "should be able to build a document header" do
    header = Absa::H2h::Transmission::Header.new(@hash[:transmission][:header])

    string = " " * 200
    string[0,55] = "000T#{Time.now.strftime("%Y%m%d")}00345DOUGLAS ANDERSON              1234567"
    string[178,22] = "SPECIAL TOKEN HERE    "

    header.to_s.should == string
  end
      
end