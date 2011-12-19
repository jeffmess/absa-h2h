module Absa
  module H2h
    module Transmission
      class AccountHolderVerification < UserSet
        
        class Header < Record; end
        class Trailer < Record; end
        class InternalAccountDetail < Record; end
        class ExternalAccountDetail < Record; end
        
        def validate! 
          unless @trailer.no_det_recs == @transactions.length.to_s
            raise "no_det_recs mismatch: expected #{@trailer.no_det_recs}, got #{@transactions.length}" 
          end
        end

      end      
    end
  end
end