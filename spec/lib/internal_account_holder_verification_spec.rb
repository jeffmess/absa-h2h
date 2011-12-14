require 'spec_helper'

describe Absa::H2h::InternalAccountHolderVerification do
  
  before(:each) do
    @hash = {
      transmission: {
        internal_account_holder_verification: {
          header: {
            rec_id: "030",
            rec_status: "T",
            gen_no: "5",
            dept_code: "6"
          },
          trailer: {
            rec_id: "039",
            rec_status: "T",
            no_det_recs: "3",
            acc_total: "6554885370"
          },
          transaction: {
            rec_id: "031",
            rec_status: "T",
            seq_no: "1",
            acc_no: "340532455403",
            idno: "8008065052081",
            initials: "DA",
            surname: "Anderson",
            return_code_1: "0",
            return_code_2: "0",
            return_code_3: "0",
            return_code_4: "0",
            user_ref: "AND033"
          }          
        }
      }
    }
  end
  
  it "should be able to build a header" do
    header = Absa::H2h::InternalAccountHolderVerification::Header.new(@hash[:transmission][:internal_account_holder_verification][:header])

    string = " " * 200
    string[0,17] = "030T0000005000006"

    header.to_s.should == string
  end
  
  it "should be able to build a trailer" do
    header = Absa::H2h::InternalAccountHolderVerification::Trailer.new(@hash[:transmission][:internal_account_holder_verification][:trailer])

    string = " " * 200
    string[0,29] = "039T0000003000000006554885370"

    header.to_s.should == string    
  end
  
  it "should be able to build a transaction record" do
    
  end
      
end