module Absa
  module H2h
    module Transmission
      module AccountHolderVerification
        class Header < Record; end
        class Trailer < Record; end
        class InternalAccountDetail < Record; end
        class ExternalAccountDetail < Record; end
        
        def self.build(content)
          transactions = content[:transactions].map do |transaction|
            class_name = "Absa::H2h::Transmission::AccountHolderVerification::#{transaction[:type].camelize}"
            class_name.constantize.new(transaction[:content])
          end
          
          {
            header: Header.new(content[:header]),
            trailer: Trailer.new(content[:trailer]),
            transactions: transactions            
          }          
        end
      end      
    end
  end
end