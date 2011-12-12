require 'spec_helper'

describe Absa::H2h do
  
  before(:all) do
    @hash = {
      transmission_header: {
        th_rec_id: "000",
        th_rec_status: "T",
        th_date: "20111112"
      }
    }
  end
  
  it "should do somethinf" do
    document = Absa::H2h.build(@hash)
    puts document.inspect
  end
  
end