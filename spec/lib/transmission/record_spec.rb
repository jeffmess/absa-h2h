require 'spec_helper'

describe Absa::H2h::Transmission::Record do
    
  it "should provide the default options for an input record" do
    response = Absa::H2h::Transmission::Record.input_template('account_holder_verification', 'internal_account_detail')
    
    response.should == {
      :rec_id=>"031", 
      :rec_status=>nil, 
      :seq_no=>nil, 
      :account_number=>nil, 
      :id_number=>nil, 
      :initials=>nil, 
      :surname=>nil, 
      :return_code_1=>"00", 
      :return_code_2=>"00", 
      :return_code_3=>"00", 
      :return_code_4=>"00", 
      :user_ref=>nil
    }
  end
      
end