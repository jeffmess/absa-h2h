module Absa
  module H2h
    module Transmission
      class AccountHolderVerification < Set
        class Header < Record; end
        class Trailer < Record; end
        class InternalAccountDetail < Record; end
        class ExternalAccountDetail < Record; end
        
        def validate! 
          unless trailer.no_det_recs == transactions.length.to_s
            raise "no_det_recs mismatch: expected #{trailer.no_det_recs}, got #{transactions.length}" 
          end

          unless transactions.map {|t| t.seq_no} == (1..(transactions.length)).map(&:to_s).to_a
            raise "seq_no mismatch: #{transactions.map {|t| t.seq_no}}"
          end             
        end
      end      
    end
  end
end