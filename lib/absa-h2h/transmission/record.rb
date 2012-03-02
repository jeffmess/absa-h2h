module Absa::H2h::Transmission
    
  class Record
    include Strata::RecordWriter
    extend Strata::RecordWriter::ClassMethods
    
    set_record_length 198
    set_delimiter "\r\n"
    set_allowed_characters ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a.map(&:to_s) + ['.','/','-','&','*',',','(',')','<','+','$',';','>','=',"'",' '] # move to config file

    def initialize(options = {})
      set_layout_variables(options)
      validate! options
    end

  end
  
end