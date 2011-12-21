module Absa::H2h::Transmission
    
  class Record
    include RecordWriter
    extend RecordWriter::ClassMethods

    def initialize(options = {})
      set_layout_variables(options)
      validate! options
    end
    
    def self.matches_definition?(string)
      self.class_layout_rules.each do |k,v|
        offset = v['offset'] - 1
        length = v['length']
        regex = v['regex']
        value = string[offset,length]
        
        if k == 'rec_id'
          value = value
        elsif v['a_n'] == 'A'
          value = value.rstrip
        elsif v['a_n'] == 'N'
          value = value.to_i.to_s
        end
        
        return false if regex and not value =~ /#{regex}/
      end
      
      true
    end
    
    def self.string_to_hash(string)
      hash = {}
      
      self.class_layout_rules.each do |k,v|
        offset = v['offset'] - 1
        length = v['length']
        value = string[offset, length]
        
        if k == 'rec_id'
          value = value
        elsif v['a_n'] == 'A'
          value = value.rstrip
        elsif v['a_n'] == 'N'
          value = value.to_i.to_s
        end
        
        hash[k.to_sym] = value
      end
      
      hash
    end
    
    def self.from_s(string)
      options = self.string_to_hash(string)
      record = self.new(options)
    end
        
  end
  
end