require 'spec_helper'

describe Absa::H2h::Transmission::AccountHolderVerification do
  
  before(:each) do
    
    @internal_section_content = [
      {type: 'header', data: {
        rec_id: "030",
        rec_status: "T",
        gen_no: "5",
        dept_code: "6"
      }},
      {type: 'internal_account_detail', data: {
        rec_id: "031",
        rec_status: "T",
        seq_no: "1",
        acc_no: "1094402524",
        idno: "6703085829086",
        initials: "M",
        surname: "CHAUKE",
        return_code_1: "0",
        return_code_2: "0",
        return_code_3: "0",
        return_code_4: "0",
        user_ref: "1495050000600002236"
      }},
      {type: 'internal_account_detail', data: {
        rec_id: "031",
        rec_status: "T",
        seq_no: "2",
        acc_no: "1094402524",
        idno: "6703085829086",
        initials: "S",
        surname: "CHAUKE",
        return_code_1: "0",
        return_code_2: "0",
        return_code_3: "0",
        return_code_4: "0",
        user_ref: "1495050000600002236"
      }},
      {type: 'trailer', data: {
        rec_id: "039",
        rec_status: "T",
        no_det_recs: "2",
        acc_total: "6554885370"
      }}
    ]
    
    @external_section_content = [
      {type: 'header', data: {
        rec_id: "030",
        rec_status: "T",
        gen_no: "5",
        dept_code: "6"
      }},
      {
        type: 'external_account_detail', 
        data: {
          rec_id: "031",
          rec_status: "T",
          seq_no: "1",
          acc_no: "1094402524",
          idno: "6703085829086",
          initials: "DA",
          surname: "Anderson",
          return_code_1: "0",
          return_code_2: "0",
          return_code_3: "0",
          return_code_4: "0",
          user_ref: "AND033",
          branch_code: "255023",
          originating_bank: "000060",
          ld_code: "LD00000",
          return_code_5: "0",
          return_code_6: "0",
          return_code_7: "0",
          return_code_8: "0",
          return_code_9: "0",
          return_code_10: "0",
        }
      },
      {type: 'trailer', data: {
        rec_id: "039",
        rec_status: "T",
        no_det_recs: "1",
        acc_total: "6554885370"
      }}
    ]
    
    @hash = {
      type: 'document',
      data: [
          {type: 'account_holder_verification', data: @internal_section_content},
          {type: 'account_holder_verification',data: @external_section_content}
        ]
    }
  end
  
  it "should be able to build a header" do
    header = Absa::H2h::Transmission::AccountHolderVerification::Header.new(@internal_section_content[0][:data])
  
    string = " " * 198 + "\r\n"
    string[0,17] = "030T0000005000006"
  
    header.to_s.should == string
  end
  
  it "should be able to build a trailer" do
    header = Absa::H2h::Transmission::AccountHolderVerification::Trailer.new(@internal_section_content[-1][:data])
  
    string = " " * 198 + "\r\n"
    string[0,29] = "039T0000002000000006554885370"
  
    header.to_s.should == string    
  end
  
  it "should be able to build an internal transaction record" do
    string1 = " " * 198 + "\r\n"
    string2 = " " * 198 + "\r\n"
    string1[0,143] = "031T00000010000000010944025246703085829086M  CHAUKE                                                      000000001495050000600002236           "
    string2[0,143] = "031T00000020000000010944025246703085829086S  CHAUKE                                                      000000001495050000600002236           "
    
    result = @internal_section_content[1..-2].map do |t|
      Absa::H2h::Transmission::AccountHolderVerification::InternalAccountDetail.new(t[:data]).to_s
    end.join
    
    result.should == (string1 + string2)
  end
  
  it "should be able to build an external transaction record" do
    string = " " * 198 + "\r\n"
    string[0,174] = "031T00000010000000010944025246703085829086DA ANDERSON                                                    00000000AND033                        255023000060LD00000000000000000"
    
    result = @external_section_content[1..-2].map do |t|
      Absa::H2h::Transmission::AccountHolderVerification::ExternalAccountDetail.new(t[:data]).to_s
    end.join
    
    result.should == string
  end
  
  it "should validate that the number of transactions matches the specified amount in the trailer" do
    lambda {Absa::H2h::Transmission::AccountHolderVerification::build(@internal_section_content)}.should_not raise_error(Exception)
    
    @internal_section_content[-1][:data][:no_det_recs] = "3"
    lambda {Absa::H2h::Transmission::AccountHolderVerification::build(@internal_section_content)}.should raise_error(Exception, "no_det_recs mismatch: expected 3, got 2")
  end
  
  it "should validate that the transaction sequence numbers are a contigious index of numbers" do
    lambda {Absa::H2h::Transmission::AccountHolderVerification::build(@internal_section_content)}.should_not raise_error(Exception)
    
    @internal_section_content[1][:data][:seq_no] = "2"
    lambda {Absa::H2h::Transmission::AccountHolderVerification::build(@internal_section_content)}.should raise_error(Exception, 'seq_no mismatch: ["2", "2"]')
  end
  
      
end