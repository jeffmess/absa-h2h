
# {
#   type: 'document',
#   data: [
#     {type: 'header', data: {}},
#     {type: 'account_holder_verification', data: [          
#     ]},
#     {type: 'eft', data: [
#       {type: 'header', data: {}},
#       {type: 'trailer', data: {}}
#     ]},
#     {type: 'eft_output', data: [
#       {type: 'header', data: {}},
#       {type: 'unpaid', data: [
#         {type: 'header', data: {}},
#         {type: 'transaction', data: {}},
#         {type: 'transaction', data: {}},
#         {type: 'transaction', data: {}},
#         {type: 'trailer', data: {}}
#       ]},
#       {type: 'redirect', data: [
#         {type: 'header', data: {}},
#         {type: 'distribution_transaction', data: {}},
#         {type: 'distribution_transaction', data: {}},
#         {type: 'distribution_transaction', data: {}},
#         {type: 'trailer', data: {}}
#       ]},
#       {type: 'trailer', data: {}}
#     ]},
#     {type: 'trailer', data: {}}
#   ]
# }


module Absa::H2h::Transmission
  class Set
    
    attr_accessor :records
    
    def initialize
      self.records = []
    end
    
    def self.build(data)
      set = self.new
      
      data.each do |hash|  
        if hash[:data].is_a? Array
          klass = "Absa::H2h::Transmission::#{hash[:type].capitalize.camelize}".constantize
          set.records << klass.build(hash[:data])
        else
          klass = "Absa::H2h::Transmission::#{self.partial_class_name}::#{hash[:type].capitalize.camelize}".constantize
          set.records << klass.new(hash[:data])
        end
      end
      
      set.validate!
      set
    end
    
    def header
      records[0]
    end
    
    def trailer
      records[-1]
    end
    
    def transactions
      records[1..-2]
    end
    
    def validate!
      
    end
    
    def to_s
      string = ""
      records.each {|record| string += record.to_s }
      string
    end
    
    def self.for_record_id(record_id) # move this logic to yml file
      case record_id
      when '000','999'
        return Absa::H2h::Transmission::Document
      when '030','031','039'
        return Absa::H2h::Transmission::AccountHolderVerification
      when '001'
        return Absa::H2h::Transmission::Eft
      #when '010','011','013','014','016','017','018','019'
      #  return Absa::H2h::Transmission::EftOutput
      end
    end
    
    def self.trailer_id(klass)
      case klass.name
      when 'Absa::H2h::Transmission::Document'
        return '999'
      when 'Absa::H2h::Transmission::AccountHolderVerification'
        return '039'
      #when Absa::H2h::Transmission::EftOutput
      #  return '019'
      end  
      # when '010','011','013','014','016','017','018','019'
      #        return Absa::H2h::Transmission::EftOutput
      #      end
      
    end  
    
    def self.is_trailer_record?(set, record)
      record_id = record[0,3]
      return true if set == Absa::H2h::Transmission::Eft and record_id == "001" and record[4,2] == "92"
      self.trailer_id(set) == record_id
    end
    
    def self.process_record(record)
      set_info = {}
      
      self.record_types.each do |record_type|
        klass = "#{self.name}::#{record_type.camelize}".constantize

        if klass.matches_definition?(record)
          options = klass.string_to_hash(record)
          set_info = {type: record_type, data: options}
        end
      end            
      
      set_info
    end
    
    def self.hash_from_s(string)
      set_info = {type: self.partial_class_name.underscore, data: []}
      lines = string.split(/^/)
            
      # look for rec_ids, split into chunks, and pass each related class a piece of string
      
      buffer = []
      current_set = nil
      
      lines.each do |line|
        record_id = line[0..2]
        
        if Set.for_record_id(record_id) == self
          record = line[0, 198]
          set_info[:data] << self.process_record(record)
        else
          subset = Set.for_record_id(record_id)          
          buffer << line
          
          if self.is_trailer_record?(subset, line)
            set_info[:data] << subset.hash_from_s(buffer.join)
            buffer = []
          end
        end
      end
      
      set_info
    end
    
    def self.record_types
      self.layout_rules.map {|k,v| k}
    end
    
    def self.module_name
      self.name.split("::")[0..-1].join("::")
    end
    
    def self.partial_class_name
      self.name.split("::")[-1]
    end
    
    def self.layout_rules
      file_name = "./lib/config/#{self.partial_class_name.underscore}.yml"
      
      YAML.load(File.open(file_name))
    end
   
  end
end