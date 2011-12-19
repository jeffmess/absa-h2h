require 'spec_helper'

describe Absa::H2h::Transmission::Eft::StandardRecord do
  before(:each) do
    @hash = {
      transmission: {
        user_sets: [{
          type: 'eft',
          content: {
            transactions: [{
              type: "standard_record", 
              content: {
                rec_id: "001",
                rec_status: "T",
                bankserv_record_identifier: "50",
                user_branch: "632005",
                user_nominated_account: "4053538939",
                user_code: "9534",
                user_sequence_number: "1",
                homing_branch: "632005",
                homing_account_number: "01019611899",
                type_of_account: "1",
                amount: "1000",
                action_date: Time.now.strftime("%y%m%d"),
                entry_class: "44",
                tax_code: "0",
                user_reference: "ALIMITTST1SPP    040524 01",
                homing_account_name: "HENNIE DU TOIT   040524",
                homing_institution: "21"
              }
            },{
              type: "contra_record",
              content: {
                rec_id: "001",
                rec_status: "T",
                bankserv_record_identifier: "52",
                user_branch: "632005",
                user_nominated_account: "4053538939",
                user_code: "9534",
                user_sequence_number: "8",
                homing_branch: "632005",
                homing_account_number: "4053538939",
                type_of_account: "1",
                amount: "16028000",
                action_date: Time.now.strftime("%y%m%d"),
                entry_class: "10",
                user_reference: "ALIMITTST1CONTRA 040524 08"
              }
            }],
          }
        }]
      }
    }
    @eft_transaction = @hash[:transmission][:user_sets].first[:content][:transactions].first[:content]
    @contra_transaction = @hash[:transmission][:user_sets].first[:content][:transactions].last[:content]
  end
  
  it "should be able to build an eft transaction record" do
    record = Absa::H2h::Transmission::Eft::StandardRecord.new(@eft_transaction)
    today = Time.now.strftime("%y%m%d")
    string =" "*200
    string[0,172] = "001T5063200504053538939953400000163200501019611899100000001000#{today}440   ALIMITTST1SPP    040524 01    HENNIE DU TOIT   040524                                           21"
    string[134, 20] = "0" * 20
    
    record.to_s.should == string
  end
  
  it "should be able to build an eft contra record" do
    record = Absa::H2h::Transmission::Eft::ContraRecord.new(@contra_transaction)
    
    today = Time.now.strftime("%y%m%d")
    string =" "*200
    string[0,104] = "001T5263200504053538939953400000863200504053538939100016028000#{today}100000ALIMITTST1CONTRA 040524 08    "
    
    record.to_s.should == string
  end
  
  it "should raise an exception if the user reference has blank values for pos 1-10" do
    @eft_transaction[:user_reference] = "               0404404"
    lambda {Absa::H2h::Transmission::Eft::StandardRecord.new(@eft_transaction)}.should raise_error("user_reference: Position 1 - 10 is compulsory. Please provide users abbreviated name.")
  end
  
end