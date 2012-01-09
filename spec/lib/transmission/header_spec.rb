require 'spec_helper'

describe Absa::H2h do
  
  before(:each) do
    @hash = {
      transmission: {
        header: {
          rec_id: "000",
          rec_status: "T",
          th_date: "20111221",
          th_client_code: "345",
          th_client_name: "DOUGLAS ANDERSON",
          th_transmission_no: "1234567",
          th_destination: "0",
          th_for_use_of_ld_user: "Special Token Here"
        }
      }
    }
  end
  
  it "should be able to build a document header" do
    header = Absa::H2h::Transmission::Document::Header.new(@hash[:transmission][:header])
    expected_string = File.open('./spec/examples/transmission_header_file.txt', "rb").read
    header.to_s.should == expected_string
  end
      
end