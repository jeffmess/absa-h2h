require 'spec_helper'

describe Absa::H2h do
  
  before(:each) do
    @hash = {
      transmission_header: {
        th_rec_id: "000",
        th_rec_status: "T",
        th_date: "20111112",
        th_client_code: "12345",
        th_client_name: "Douglas Anderson",
        th_transmission_no: "1234567",
        th_for_use_of_ld_user: "Special Token Here"
      }
    }
  end
  
  it "should do somethinf" do
    document = Absa::H2h.build(@hash)
    puts document.inspect
  end
  
  it "should raise an exception if a provided field exceeds the allowed length" do
    @hash[:transmission_header][:th_rec_id] = "0000"
    lambda {document = Absa::H2h.build(@hash)}.should raise_error("th_rec_id: Input too long")
  end
  
  it "should raise an exception if a provided field fails to pass a specified field format" do
    @hash[:transmission_header][:th_rec_id] = "100"
    lambda {document = Absa::H2h.build(@hash)}.should raise_error("th_rec_id: Invalid data")
  end
  
  it "should raise an exception if a alpha character is passed into a numeric-only field" do
    @hash[:transmission_header][:th_client_code] = "1234A"
    lambda {document = Absa::H2h.build(@hash)}.should raise_error("th_client_code: Numeric value required")
  end
  
  it "should output a string of 200 characters" do
    document = Absa::H2h.build(@hash)
    puts document.to_s
  end
  
end