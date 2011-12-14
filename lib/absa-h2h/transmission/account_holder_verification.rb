module Absa
  module H2h
    module Transmission
      module AccountHolderVerification
            
        class Header
          include InputValidation
          include RecordWriter
  
          def initialize(options = {})
            set_layout_variables(options)
            validate! options
          end
        end
      
        class Trailer
          include InputValidation
          include RecordWriter
        
          def initialize(options = {})
            set_layout_variables(options)
            validate! options
          end
        end
      
        class InternalAccountDetail
          include InputValidation
          include RecordWriter
        
          def initialize(options = {})
            set_layout_variables(options)
            validate! options
          end        
        end
        
        class ExternalAccountDetail
          include InputValidation
          include RecordWriter
        
          def initialize(options = {})
            set_layout_variables(options)
            validate! options
          end        
        end
        
      end      
    end
  end
end