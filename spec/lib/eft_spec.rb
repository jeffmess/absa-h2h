require 'spec_helper'

describe Absa::H2h::Transmission::Eft::Header do
  
  before(:each) do
    @hash = {
      transmission: {
        header: {},
        trailer: {},
        user_sets: [{
          type: 'eft',
          content: {
            header: {
              rec_id: "001",
              rec_status: "T",
              bankserv_record_identifier: "04",
              bankserv_user_code: "9534",
              bankserv_creation_date: Time.now.strftime("%y%m%d"),
              bankserv_purge_date: Time.now.strftime("%y%m%d"),
              first_action_date: Time.now.strftime("%y%m%d"),
              last_action_date: Time.now.strftime("%y%m%d"),
              first_sequence_number: "1",
              user_generation_number: "37",
              type_of_service: "CORPSSV",
            },
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
              },
            }],
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
    
    @invalid_transaction = {
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
        action_date: (Time.now + (2*24*3600)).strftime("%y%m%d"),
        entry_class: "44",
        tax_code: "0",
        user_reference: "ALIMITTST1SPP    040524 01",
        homing_account_name: "HENNIE DU TOIT   040524",
        homing_institution: "21"
      },
    }
    
    @user_set = @hash[:transmission][:user_sets].first[:content]
    today = Time.now.strftime("%y%m%d")
    @header =" "*200
    @header[0,51] = "001T049534#{today}#{today}#{today}#{today}0000010037CORPSSV"
    
    @trailer =" "*200
    @trailer[0,88] = "001T929534000001000016#{today}#{today}000014000002000002000020308000000020308000036311034141"
    
    @transaction =" "*200
    @transaction[0,172] = "001T5063200504053538939953400000163200501019611899100000001000#{today}440   ALIMITTST1SPP    040524 01    HENNIE DU TOIT   040524                                           21"
    @transaction[134, 20] = "0" * 20
  end
  
  it "should be able to build an eft user set" do
    eft = Absa::H2h::Transmission::Eft.build(@user_set)
    eft.header.to_s.should == @header
    eft.trailer.to_s.should == @trailer
    eft.transactions.first.to_s.should == @transaction
  end
  
  it "should validate the action date for the transaction records" do
    @user_set[:transactions] << @invalid_transaction
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("action_date: Must be within the range of first_action_date and last_action_date")
  end
  
end