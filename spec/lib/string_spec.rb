require 'spec_helper'

describe String do
  
  it "should be able to downcase and underscore the module names" do
    "InternalAccountHolderVerification".underscore.should == "internal_account_holder_verification"
  end
  
end