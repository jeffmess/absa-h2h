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
        
        def self.build(options)
          record = self.new
          record.build_header options[:header]
          record.build_trailer options[:trailer]

          options[:transactions].each do |transaction|
            puts transaction.inspect
            record.build_transaction(transaction)
          end

          record
        end
        
        def build_header(options = {})
          @header = Transmission::Header.new(options)
        end

        def build_trailer(options = {})
          @trailer = Transmission::Trailer.new(options)
        end

        def build_user_set(options = {})
          class_name = "Absa::H2h::Transmission::#{options[:type].camelize}"
          puts class_name
          @user_sets.push class_name.constantize.build(options[:content])
        end
      end
      
    end
  end
end