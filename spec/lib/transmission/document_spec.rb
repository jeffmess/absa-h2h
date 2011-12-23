require 'spec_helper'

describe Absa::H2h::Transmission::Document do
  
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
      {type: 'trailer', data: {
        rec_id: "039",
        rec_status: "T",
        no_det_recs: "1",
        acc_total: "6554885370"
      }}
    ]
    
    @hash = {type: 'document', data: [
        {type: 'header', data: {
          rec_id: "000",
          th_rec_status: "T",
          th_date: Time.now.strftime("%Y%m%d"),
          th_client_code: "345",
          th_client_name: "DOUGLAS ANDERSON",
          th_transmission_no: "1234567",
          th_destination: "0",
          th_for_use_of_ld_user: "SPECIAL TOKEN HERE"
        }},
        {
          type: 'account_holder_verification',
          data: @internal_section_content
        },
        {type: 'trailer', data: {
          rec_id: "999",
          tt_rec_status: "T",
          tt_no_of_recs: "7",
        }}
      ]
    }    
  end
  
  it "should raise an exception is any of the provided arguments are not strings" do
    @internal_section_content[-1][:data][:no_det_recs] = 1
    lambda {document = Absa::H2h::Transmission::Document.build(@hash[:data])}.should raise_error("no_det_recs: Argument is not a string")
  end

  it "should raise an exception if a provided field exceeds the allowed length" do
    @hash[:data][0][:data][:rec_id] = "0000"
    lambda {document = Absa::H2h::Transmission::Document.build(@hash[:data])}.should raise_error("rec_id: Input too long")
  end

  it "should raise an exception if a provided field fails to pass a specified field format" do
    @hash[:data][0][:data][:rec_id] = "100"
    lambda {document = Absa::H2h::Transmission::Document.build(@hash[:data])}.should raise_error("rec_id: Invalid data")
  end

  it "should raise an exception if an alpha character is passed into a numeric-only field" do
    @hash[:data][0][:data][:th_client_code] = "1234A"
    lambda {document = Absa::H2h::Transmission::Document.build(@hash[:data])}.should raise_error("th_client_code: Numeric value required")
  end
  
  it "should be able to build a complete document" do
    document = Absa::H2h::Transmission::Document.build(@hash[:data])
    
    string = "000T#{Time.now.strftime("%Y%m%d")}00345DOUGLAS ANDERSON              123456700000                                                                                                                       SPECIAL TOKEN HERE  \r
030T0000005000006                                                                                                                                                                                     \r
031T00000010000000010944025246703085829086M  CHAUKE                                                      000000001495050000600002236                                                                  \r
039T0000001000000006554885370                                                                                                                                                                         \r
999T000000007                                                                                                                                                                                         \r
"
    
    document.to_s.should == string
  end
  
  context "when parsing a file" do
    
    it "should build a valid document" do
      file_names = ['ahv_input_file.txt','eft_input_file.txt','eft_output_file.txt']
      
      file_names.each do |file_name|
        input_string = File.open("./spec/examples/#{file_name}", "rb").read
        document = Absa::H2h::Transmission::Document.from_s(input_string)
        
        output_string = document.to_s
        output_string.should == input_string
      end
    end
    
  end
  
end