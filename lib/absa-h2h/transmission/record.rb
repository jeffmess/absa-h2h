module Absa::H2h::Transmission
    
  class Record
    include RecordWriter
    extend RecordWriter::ClassMethods

    def initialize(options = {})
      set_layout_variables(options)
      validate! options
    end
    
    def self.matches_definition?(string)
      puts string
      
      self.class_layout_rules.each do |field, rule|
        puts rule.inspect
        value = self.retrieve_field_value(string, field, rule)
        regex = rule['regex']
        return false if regex and not value =~ /#{regex}/
      end
      
      puts "matched! #{self.name}"
      true
    end
    
    def self.string_to_hash(string)
      hash = {}
      
      self.class_layout_rules.each do |field, rule|
        hash[field.to_sym] = self.retrieve_field_value(string, field, rule)
      end
      
      hash
    end
    
    def self.from_s(string)
      options = self.string_to_hash(string)
      record = self.new(options)
    end
    
    protected
    
    def self.retrieve_field_value(string, field, rule)
      offset = rule['offset'] - 1
      length = rule['length']
      field_type = rule['a_n']
      
      i_dont_strip = ['rec_id','bankserv_creation_date','bankserv_purge_date','first_action_date','last_action_date','action_date']
      
      value = string[offset, length]
      value = value.rstrip if field_type == 'A' and not i_dont_strip.include?(field)
      value = value.to_i.to_s if field_type == 'N' and not i_dont_strip.include?(field)
      value
    end
        
  end
  
end