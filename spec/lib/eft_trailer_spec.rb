require 'spec_helper'

describe Absa::H2h::Transmission::Eft::Trailer do
  before(:each) do
    @hash = {
      transmission: {
        sections: [{
          type: 'eft',
          content: {
            trailer: {
              rec_id: "001",
              rec_status: "T",
              bankserv_record_identifier: "92",
              bankserv_user_code: "9534",
              first_sequence_number: "1",
              last_sequence_number: "16",
              first_action_date: Time.now.strftime("%y%m%d"),
              last_action_date: Time.now.strftime("%y%m%d"),
              no_debit_records: "14",
              no_credit_records: "2",
              no_contra_records: "2",
              total_debit_value: "20308000",
              total_credit_value: "20308000",
              hash_total_of_homing_account_numbers: "36311034141",
            },
          }
        }]
      }
    }
    @eft_trailer = @hash[:transmission][:sections].first[:content][:trailer]
  end
  
  it "should be able to build a document trailer" do
    trailer = Absa::H2h::Transmission::Eft::Trailer.new(@eft_trailer)
    today = Time.now.strftime("%y%m%d")
    
    string =" "*200
    string[0,88] = "001T929534000001000016#{today}#{today}000014000002000002000020308000000020308000036311034141"
    
    trailer.to_s.should == string
  end

  
end