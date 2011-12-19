require 'spec_helper'

describe Absa::H2h::Transmission::File do
  
  before(:each) do
    @internal_section_content = {
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
      transactions: [{type: 'internal_account_detail', content: {
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
      }}]
    }
    
    @hash = {
      transmission: {
        header: {
          th_rec_id: "000",
          th_rec_status: "T",
          th_date: Time.now.strftime("%Y%m%d"),
          th_client_code: "345",
          th_client_name: "Douglas Anderson",
          th_transmission_no: "1234567",
          th_for_use_of_ld_user: "Special Token Here",
          th_destination: ""
        },
        trailer: {
          tt_rec_id: "999",
          tt_rec_status: "T",
          tt_no_of_recs: "7",
        },
        user_sets: [
          {
            type: 'account_holder_verification',
            content: @internal_section_content
          }
        ]
      }
    }
  end

  it "should raise an exception if a provided field exceeds the allowed length" do
    @hash[:transmission][:header][:th_rec_id] = "0000"
    lambda {document = Absa::H2h::Transmission::File.build(@hash)}.should raise_error("th_rec_id: Input too long")
  end

  it "should raise an exception if a provided field fails to pass a specified field format" do
    @hash[:transmission][:header][:th_rec_id] = "100"
    lambda {document = Absa::H2h::Transmission::File.build(@hash)}.should raise_error("th_rec_id: Invalid data")
  end

  it "should raise an exception if a alpha character is passed into a numeric-only field" do
    @hash[:transmission][:header][:th_client_code] = "1234A"
    lambda {document = Absa::H2h::Transmission::File.build(@hash)}.should raise_error("th_client_code: Numeric value required")
  end
  
  it "should be able to build a complete file" do
    Date
    file = Absa::H2h::Transmission::File.build(@hash)
    
    string = "000T#{Time.now.strftime("%Y%m%d")}00345Douglas Anderson              1234567                                                                                                                            Special Token Here    \r
030T0000005000006                                                                                                                                                                                       \r
031T00000010000000010944025246703085829086M  CHAUKE                                                      000000001495050000600002236                                                                    \r
039T0000003000000006554885370                                                                                                                                                                           \r
999T000000007                                                                                                                                                                                           "
    
    file.to_s.should == string
  end

end