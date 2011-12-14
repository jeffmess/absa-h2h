module Absa
  module H2h
    module Transmission
      
      class Record
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