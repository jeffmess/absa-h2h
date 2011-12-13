require 'spec_helper'

describe Absa::H2h do
  
  before(:each) do
    @hash = {
      transmission_trailer: {
        tt_rec_id: "999",
        tt_rec_status: "T",
        tt_no_of_recs: "7",
      }
    }
  end
  
  it "should be able to build a document trailer" do
    trailer = Absa::H2h::Transmission::Trailer.new(@hash[:transmission_trailer])

    string = " " * 200
    string[0,13] = "999T000000007"

    trailer.to_s.should == string
  end
  
end