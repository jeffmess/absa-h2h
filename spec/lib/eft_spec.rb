require 'spec_helper'

describe Absa::H2h::Transmission::Eft do
  
  before(:each) do
    @hash = {
      type: 'document',
      data: [
        {type: 'header', data: {}},
        {type: 'eft', data: [
            {type: 'header', data: {
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
            }},
            {
              type: "standard_record", 
              data: {
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
                user_ref: "ALIMITTST1SPP    040524 01",
                homing_account_name: "HENNIE DU TOIT   040524",
                homing_institution: "21"
            }},
            {type: "contra_record", data: {
                rec_id: "001",
                rec_status: "T",
                bankserv_record_identifier: "52",
                user_branch: "632005",
                user_nominated_account: "4053538939",
                user_code: "9534",
                user_sequence_number: "2",
                homing_branch: "632005",
                homing_account_number: "4053538939",
                type_of_account: "1",
                amount: "1000",
                action_date: Time.now.strftime("%y%m%d"),
                entry_class: "10",
                user_ref: "ALIMITTST1CONTRA 040524 08"
            }},
            {type: 'trailer', data: {
              rec_id: "001",
              rec_status: "T",
              bankserv_record_identifier: "92",
              bankserv_user_code: "9534",
              first_sequence_number: "1",
              last_sequence_number: "2",
              first_action_date: Time.now.strftime("%y%m%d"),
              last_action_date: Time.now.strftime("%y%m%d"),
              no_debit_records: "1",
              no_credit_records: "1",
              no_contra_records: "1",
              total_debit_value: "1000",
              total_credit_value: "1000",
              hash_total_of_homing_account_numbers: "5073150838",
            }}
        ]},
        {type: 'trailer', data: {}}
      ]
    }
    
    @invalid_transaction = {
      type: "standard_record", 
      data: {
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
        user_ref: "ALIMITTST1SPP    040524 01",
        homing_account_name: "HENNIE DU TOIT   040524",
        homing_institution: "21"
      },
    }
    
    @user_set = @hash[:data][1][:data]
    today = Time.now.strftime("%y%m%d")
    @header = " " * 198 + "\r\n"
    @header[0,51] = "001T049534#{today}#{today}#{today}#{today}0000010037CORPSSV"
    
    @trailer = " " * 198 + "\r\n"
    @trailer[0,88] = "001T929534000001000002#{today}#{today}000001000001000001000000001000000000001000005073150838"    
    @transaction = " " * 198 + "\r\n"
    @transaction[0,172] = "001T5063200504053538939953400000163200501019611899100000001000#{today}440   ALIMITTST1SPP    040524 01    HENNIE DU TOIT   040524                                           21"
    @transaction[134, 20] = "0" * 20
    
    @additional_transactions = [{type: "standard_record", data: { rec_id: "001", rec_status: "T", bankserv_record_identifier: "50",user_branch: "632005",
      user_nominated_account: "4053538939", user_code: "9534",user_sequence_number: "3",homing_branch: "632005",homing_account_number: "01019611899",type_of_account: "1",
      amount: "12000",action_date: Time.now.strftime("%y%m%d"),entry_class: "44",tax_code: "0",user_ref: "ALIMITTST1SPP    040524 01",homing_account_name: "HENNIE DU TOIT   040524",
      homing_institution: "21"
    }},
    {type: "standard_record", data: { rec_id: "001", rec_status: "T", bankserv_record_identifier: "50",user_branch: "632005",
      user_nominated_account: "4053538939", user_code: "9534",user_sequence_number: "4",homing_branch: "632005",homing_account_number: "01019611899",type_of_account: "1",
      amount: "1000",action_date: Time.now.strftime("%y%m%d"),entry_class: "44",tax_code: "0",user_ref: "ALIMITTST1SPP    040524 01",homing_account_name: "HENNIE DU TOIT   040524",
      homing_institution: "21"
    }},
    {type: "standard_record", data: { rec_id: "001", rec_status: "T", bankserv_record_identifier: "50",user_branch: "632005",
      user_nominated_account: "4053538939", user_code: "9534",user_sequence_number: "5",homing_branch: "632005",homing_account_number: "01019611899",type_of_account: "1",
      amount: "4000",action_date: Time.now.strftime("%y%m%d"),entry_class: "44",tax_code: "0",user_ref: "ALIMITTST1SPP    040524 01",homing_account_name: "HENNIE DU TOIT   040524",
      homing_institution: "21"
    }},
    {type: "standard_record", data: { rec_id: "001", rec_status: "T", bankserv_record_identifier: "50",user_branch: "632005",
      user_nominated_account: "4053538939", user_code: "9534",user_sequence_number: "6",homing_branch: "632005",homing_account_number: "01019611899",type_of_account: "1",
      amount: "3500",action_date: Time.now.strftime("%y%m%d"),entry_class: "44",tax_code: "0",user_ref: "ALIMITTST1SPP    040524 01",homing_account_name: "HENNIE DU TOIT   040524",
      homing_institution: "21"
    }},
    {type: "contra_record",data: {rec_id: "001",rec_status: "T",bankserv_record_identifier: "52",user_branch: "632005",user_nominated_account: "4053538939",
      user_code: "9534", user_sequence_number: "7",homing_branch: "632005",homing_account_number: "4053538939",type_of_account: "1",amount: "21500",
      action_date: Time.now.strftime("%y%m%d"),entry_class: "10",user_ref: "ALIMITTST1CONTRA 040524 08"
    }}]
  end
  
  context "building a header" do
    
    it "should be able to build a document header" do
      header = Absa::H2h::Transmission::Eft::Header.new(@user_set[0][:data])
      today = Time.now.strftime("%y%m%d")

      string = " " * 198 + "\r\n"
      string[0,51] = "001T049534#{today}#{today}#{today}#{today}0000010037CORPSSV"

      header.to_s.should == string
    end

    it "should raise an exception if a provided field exceeds the allowed length" do
      @user_set[0][:data][:rec_id] = "0000"
      lambda {document = Absa::H2h::Transmission::Eft::Header.new(@user_set[0][:data])}.should raise_error("rec_id: Input too long")
    end

    it "should raise an exception if a provided field is not a specified type" do
      @user_set[0][:data][:type_of_service] = "SAVINGS"
      lambda {document = Absa::H2h::Transmission::Eft::Header.new(@user_set[0][:data])}.should raise_error("type_of_service: Invalid data")
    end
    
  end
  
  context "building a trailer" do
  
    it "should be able to build a document trailer" do
      trailer = Absa::H2h::Transmission::Eft::Trailer.new(@user_set[-1][:data])
      today = Time.now.strftime("%y%m%d")
    
      string = " " * 198 + "\r\n"
      string[0,88] = "001T929534000001000002#{today}#{today}000001000001000001000000001000000000001000005073150838"
    
      trailer.to_s.should == string
    end
  
  end
  
  it "should be able to build an eft user set" do
    eft = Absa::H2h::Transmission::Eft.build(@user_set)
    eft.header.to_s.should == @header
    eft.trailer.to_s.should == @trailer
    eft.transactions.first.to_s.should == @transaction
  end
  
  it "should validate the action date for the transaction records" do
    @invalid_transaction[:data][:user_sequence_number] = '3'
    @user_set = @user_set[0..-2] + [@invalid_transaction] + [@user_set[-1]]
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("action_date: Must be within the range of the headers first_action_date and last_action_date")
  end
  
  it "should validate the record status of the header and trailer records" do
    @user_set[-1][:data][:rec_status] = 'L'
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("rec_status: Trailer and Header record status must be equal")
  end
  
  it "should validate the record status of the header and transaction records" do
    @user_set[1..-2].first[:data][:rec_status] = 'L'
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("rec_status: Transaction and Header record status must be equal")
  end
  
  it "should validate the first standard transaction record and header record sequence numbers" do
    @user_set[1..-2].first[:data][:user_sequence_number] = '2'
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_sequence_number: 1st Standard transactions user sequence number and the headers first sequence number must be equal.")
  end
  
  it "should check for duplicate user sequence numbers in transactions" do
    @invalid_transaction[:data][:action_date] = Time.now.strftime("%y%m%d")
    @user_set = @user_set[0..-2] + [@invalid_transaction] + [@user_set[-1]]
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_sequence_number: Duplicate user sequence number. Transactions must have unique sequence numbers!")
  end
  
  it "should check that transactions increment sequentially" do
    @invalid_transaction[:data][:user_sequence_number] = "5"
    @user_set = @user_set[0..-2] + [@invalid_transaction] + [@user_set[-1]]
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_sequence_number: Transactions must increment sequentially. Got: #{["1", "2", "5"]}")
  end
  
  it "should validate the bankserv user code in the Trailer and header" do
    @user_set[-1][:data][:bankserv_user_code] = "7890"
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("bankserv_user_code: Trailer and Header user code must be equal.")
  end
  
  it "should validate the first sequence number in the Trailer and header" do
    @user_set[-1][:data][:first_sequence_number] = "3"
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("first_sequence_number: Trailer and Header sequence number must be equal.")
  end
  
  it "should validate the first action date in the Trailer and header" do
    @user_set[-1][:data][:first_action_date] = (Time.now + (2*24*3600)).strftime("%y%m%d")
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("first_action_date: Trailer and Header first action date must be equal.")
  end
  
  it "should validate the last action date in the Trailer and header" do
    @user_set[-1][:data][:last_action_date] = (Time.now + (2*24*3600)).strftime("%y%m%d")
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("last_action_date: Trailer and Header last action date must be equal.")
  end
  
  it "should have a contra record containing the total monetary value of all preceding standard transactions" do
    @user_set[1..-2].last[:data][:amount] = "2000"
    lambda {eft = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("amount: Contra record amount must be the sum amount of all preceeding transactions. Expected 1000. Got 2000.")
  end
  
  it "should test all contra records monetary value in a given user set" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("amount: Contra record amount must be the sum amount of all preceeding transactions. Expected 20500. Got 21500.")
  end
  
  it "should test all contra records action dates in a given user set" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    today = Time.now.strftime("%y%m%d")
    @user_set[0][:data][:last_action_date] = (Time.now + (3*24*3600)).strftime("%y%m%d")
    @user_set[-1][:data][:last_action_date] = (Time.now + (3*24*3600)).strftime("%y%m%d")
    @user_set[1..-2][3][:data][:action_date] = (Time.now + (2*24*3600)).strftime("%y%m%d")
    @user_set[1..-2].last[:data][:amount] = "20500"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("action_date: Contra records action date must be equal to all preceeding standard transactions action date. Got [\"#{today}\", \"#{(Time.now + (2*24*3600)).strftime("%y%m%d")}\", \"#{today}\", \"#{today}\"].")
  end
  
  it "should validate the contra records user nominated account against all its transactions" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    @user_set[1..-2].last[:data][:amount] = "20500"
    @user_set[1..-2][-2][:data][:user_nominated_account] = "4053538949"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_nominated_account: Contra records user nominated account must match all preceeding standard transactions user nominated accounts. Got [\"4053538939\", \"4053538939\", \"4053538939\", \"4053538949\"].")
  end
  
  it "should validate the contra records user branch against all its transactions" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    @user_set[1..-2].last[:data][:amount] = "20500"
    @user_set[1..-2][-2][:data][:user_branch] = "632100"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_branch_code: Contra records user branch must match all preceeding standard transactions user branch. Got [\"632005\", \"632005\", \"632005\", \"632100\"].")
  end
  
  it "should raise an error if the contras homing branch does not match the user branch" do
    @user_set[1..-2].last[:data][:homing_branch] = "632100"
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("homing_branch: Should match the user branch. Got 632100. Expected 632005.")
  end
  
  it "should raise an error if the contras homing account number does not match the user nominated account number" do
    @user_set[1..-2].last[:data][:homing_account_number] = "2929292"
    lambda {document = Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("homing_account_number: Should match the user nominated account number. Got 2929292. Expected 4053538939.")
  end
  
  it "should raise an error if the contras user code does not match the headers bankserv user code" do
    @user_set[1..-2].last[:data][:user_code] = "8888"
    lambda { Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_code: Contra records user code must match the headers users code. Got 8888. Expected 9534.")
  end
  
  it "should raise an error if the contras user reference position 1-10 is blank" do
    @user_set[1..-2].last[:data][:user_ref] = "          CONTRA 040524 08"
    lambda { Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_ref: Position 1 - 10 is compulsory. Please provide users abbreviated name.")
  end
  
  it "should raise an error if the contras user reference position 11-16 does not match CONTRA" do
    @user_set[1..-2].last[:data][:user_ref] = "ALIMITTST1CON RA 040524 08"
    lambda { Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("user_ref: Position 11 - 16 is compulsory and must be set to 'CONTRA'. Got CON RA")
  end
  
  it "should raise an error if the trailer records last sequence number does not match the preceeding contra records sequence number" do
    @user_set[-1][:data][:last_sequence_number] = "16"
    lambda { Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("last_sequence_number: Trailer records last sequence number must match the last contra records sequence number. Got 16. Expected 2")    
  end
  
  it "should validate the contra records user nominated account against all its transactions" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    @user_set[1..-2].last[:data][:amount] = "20500"
    @user_set[-1][:data][:last_sequence_number] = "7"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("no_debit_records: Trailer records number of debit records must match the number of debit records. Expected 5. Got 1.")
  end
  
  it "should validate the number of debit transactions in a user set" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    @user_set[1..-2].last[:data][:amount] = "20500"
    @user_set[-1][:data][:last_sequence_number] = "7"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("no_debit_records: Trailer records number of debit records must match the number of debit records. Expected 5. Got 1.")
  end
  
  it "should validate the number of credit transactions in a user set" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    
    @user_set[1..-2].last[:data][:amount] = "20500"
    @user_set[-1][:data][:last_sequence_number] = "7"
    @user_set[-1][:data][:no_debit_records] = "4"
    @user_set[1..-2][5][:data][:bankserv_record_identifier] = "10"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("no_credit_records: Trailer records number of credit records must match the number of credit records and contra debit records. Expected 3. Got 1.")
  end
  
  it "should validate the number of contra transactions in a user set" do
    @user_set[-1][:data][:no_contra_records] = "2"
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("no_contra_records: Trailer records number of contra records must match the number of contra records. Expected 1. Got 2.")
  end
  
  it "should validate the total value of debit transactions and any credit contra records in the trailer" do
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    @user_set[1..-2].last[:data][:amount] = "20500"
    @user_set[-1][:data][:last_sequence_number] = "7"
    @user_set[-1][:data][:no_debit_records] = "5"
    @user_set[-1][:data][:no_credit_records] = "2"
    @user_set[-1][:data][:no_contra_records] = "2"
    @user_set[-1][:data][:total_debit_value] = "22500"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("total_debit_value: Trailer records total debit value must equal the sum amount of all transactions and credit contra records. Expected 21500. Got 22500.")
  end
  
  it "should validate the total value of credit transactions and any debit contra records in the trailer" do
    @additional_transactions.each do |t|
      t[:data][:bankserv_record_identifier] = "10" if t[:type] == "standard_record"
    end
    
    @user_set = @user_set[0..-2] + @additional_transactions + [@user_set[-1]]
    
    @user_set[1..-2].last[:data][:amount] = "20500"
    @user_set[-1][:data][:last_sequence_number] = "7"
    @user_set[-1][:data][:no_debit_records] = "1"
    @user_set[-1][:data][:no_credit_records] = "6"
    @user_set[-1][:data][:no_contra_records] = "2"
    @user_set[-1][:data][:total_debit_value] = "1000"
    
    lambda {Absa::H2h::Transmission::Eft.build(@user_set)}.should raise_error("total_credit_value: Trailer records total credit value must equal the sum amount of all transactions and debit contra records. Expected 42000. Got 1000.")
  end
  
  
end