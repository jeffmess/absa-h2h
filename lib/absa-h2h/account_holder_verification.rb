module Absa
  module H2h
    module Transmission
      class AccountHolderVerification < UserSet
        
        class Header < Record; end
        class Trailer < Record; end
        class InternalAccountDetail < Record; end
        class ExternalAccountDetail < Record; end

      end      
    end
  end
end