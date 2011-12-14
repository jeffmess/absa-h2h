module Absa
  module H2h
    module Transmission
      module Eft
        class Header
          include InputValidation
          include RecordWriter
  
          def initialize(options = {})
            set_layout_variables(options)
            validate! options
          end
        end
        
        class ContraRecord
          include InputValidation
          include RecordWriter
        
          def initialize(options = {})
            set_layout_variables(options)
            validate! options
          end
        end
        
        class StandardRecord
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
      end
    end
  end
end