require 'spec_helper'

describe Absa::H2h::Eft::RejectionCode do
  
  it "should provide a list of eft rejection reasons" do
    list = Absa::H2h::Eft::RejectionCode.reasons
    
    list.length.should == 52

    list.each do |code, reason|
      code.is_a?(Fixnum).should be_true
      reason.is_a?(String).should be_true
    end
  end
  
  it "should retrieve a rejection reason for a given code" do
    reason = Absa::H2h::Eft::RejectionCode.reason_for_code(2)
    reason.should == "NOT PROVIDED FOR"
  end
  
  it "should provide a list of eft rejection qualifiers" do
    list = Absa::H2h::Eft::RejectionCode.qualifiers
    
    list.length.should == 267
    
    list.each do |code, qualifier|
      code.is_a?(Fixnum).should be_true
      qualifier.is_a?(String).should be_true
    end
  end
  
  it "should retrieve a rejection qualifier for a given code" do
    reason = Absa::H2h::Eft::RejectionCode.qualifier_for_code(2)
    reason.should == "COURT ORDER HOLD ON ACCOUNT"
  end
  
end