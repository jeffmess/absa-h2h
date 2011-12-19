module Absa
  module H2h
    module Transmission
      class AccountHolderVerification < UserSet
        
        class Header < Record; end
        class Trailer < Record; end
        class InternalAccountDetail < Record; end
        class ExternalAccountDetail < Record; end
        
        def validate!
          #puts "validate verification user set"
          
          #puts @trailer.inspect
          
          #raise "no_det_recs: number mismatch" unless @trailer.no_det_recs == @transactions.length
        end

      end      
    end
  end
end