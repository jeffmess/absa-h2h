module Absa::H2h::Transmission
    
  class Record
    include RecordWriter
    extend RecordWriter::ClassMethods

    def initialize(options = {})
      set_layout_variables(options)
      validate! options
    end
    
    def self.matches_definition?(string)      
      self.class_layout_rules.each do |field, rule|
        value = self.retrieve_field_value(string, field, rule)
        regex = rule['regex']
        fixed_val = rule['fixed_val']
        return false if regex and not value =~ /#{regex}/
        return false if fixed_val and value != fixed_val
      end
      
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
    
    def self.template_options
      hash = {}
      
      self.class_layout_rules.each do |field, rule|
        value = rule.has_key?('fixed_val') ? rule['fixed_val'] : nil
        
        if value
          value = value.rjust(rule['length'], "0") if rule['a_n'] == 'N'
          value = value.ljust(rule['length'], " ") if rule['a_n'] == 'A'
        end
        
        hash[field.to_sym] = value
      end
      
      hash
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