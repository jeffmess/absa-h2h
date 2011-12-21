require 'spec_helper'

describe Absa::H2h do
  
  before(:each) do
    @hash = {
      transmission: {
        trailer: {
          rec_id: "999",
          tt_rec_status: "T",
          tt_no_of_recs: "7",
        }
      }
    }
  end
  
  it "should be able to build a document trailer" do
    trailer = Absa::H2h::Transmission::Document::Trailer.new(@hash[:transmission][:trailer])

    string = " " * 198 + "\r\n"
    string[0,13] = "999T000000007"

    trailer.to_s.should == string
  end
  
end